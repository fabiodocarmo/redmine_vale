class AutoIssueAttachmentTrigger < ActiveRecord::Base
  unloadable
  require 'roo'

  belongs_to :project
  belongs_to :tracker
  belongs_to :status, class_name: 'IssueStatus'

  belongs_to :attachment_auto_issue, class_name: 'AutoIssue'
  delegate :build_issue, to: :attachment_auto_issue


  DEFAULT_COLUMN = [{'subject' => nil},
                    {'issue_status' => :name},
                    {'assigned_to' => :assigned_to},
                    {'description' => nil},
                    {'due_date' => nil}]

  def create_issues(previous_issue, attachment)
    new_issue = Issue.new(project_id: attachment_auto_issue.project_id,
                          tracker_id: attachment_auto_issue.tracker_id)

    issue_columns = DEFAULT_COLUMN.concat(new_issue.available_custom_fields.map { |acf| acf.read_attribute(:name) }.map(&:strip).map {|name| {name => :custom_field} })

    spreadsheet = Roo::Spreadsheet.open(attachment.diskfile, extension: :xlsx)
    template_issue_columns = issue_columns.select { |col| col.keys.first.downcase.in? template_columns(spreadsheet) }
                                             .map { |col| { template_columns(spreadsheet).index(col.keys.first.downcase) => col } }

    invalid_issues = []
    valid_issues = []

    issues_with_valid = (2..spreadsheet.last_row).lazy.map { |i| get_column_value_from_template(spreadsheet.row(i), template_issue_columns) }
      .map { |template_issue_value| get_column_value_from_database(template_issue_value)    }
      .map { |database_issue_value| build_issue_with_default_columns(database_issue_value, previous_issue)  }
      .map { |issue_and_custom_fields| add_custom_field_to_issue(issue_and_custom_fields)   }.each_with_index do |issue, index|

      if issue.valid?
        valid_issues << issue
      else
        invalid_issues << [index + 2, issue]
      end
    end

    if invalid_issues.any?
      invalid_issues.map { |invalid_issue| [invalid_issue[0], invalid_issue[1].errors.full_messages.flatten] }
                    .map { |errors| errors[1].map { |error_msg| {error_msg => errors[0]} } }
                    .flatten.inject({}) { |value, acc| acc.merge(value) { |k, value_1, value_2| ([value_1] | [value_2]).flatten.sort } }
                    .each { |error, lines| previous_issue.errors.add(:base, "#{error}: #{[lines].join(', ')}") }

      raise ActiveRecord::RecordInvalid.new(previous_issue)
    else
      valid_issues.each do |new_issue|
        # new_issue.do_not_send_notification = true
        new_issue.save!
      end
    end
  end

  #[[string]], [{int: {a: b}}] >> [{string: {a: b}}]
  def get_column_value_from_template(row, template_issue_columns)
    template_issue_columns.map { |tic| {row[tic.keys.first] => tic.values.first } }
  end

  #[{string: {a: b}}] >> [{ object: {a: b}}]
  def get_column_value_from_database(template_issue_value)
    template_issue_value.map do |value|
      template_value = value.keys.first
      issue_transformation = value.values.first

      type = issue_transformation.values.first

      case type
      when :name
        {issue_transformation.keys.first.camelize.constantize.where(name: template_value).pluck(:id).first => issue_transformation}
      when :assigned_to
        {(Group.where(lastname: template_value).pluck(:id).first || User.where(login: template_value).pluck(:id).first) => issue_transformation}
      else
        {template_value => issue_transformation}
      end
    end
  end

  # [{ object: {a: b}}] >> [issue, custom_values]
  def build_issue_with_default_columns(database_issue_value, previous_issue)
    issue = build_issue(previous_issue)

    issue.safe_attributes = database_issue_value.map do |value|
      database_value = value.keys.first
      issue_transformation = value.values.first

      type = issue_transformation.values.first
      case type
      when :name
        {"#{issue_transformation.keys.first}_id" => database_value} if database_value
      when :assigned_to
        {"assigned_to_id" => database_value} if database_value
      when :custom_field
        nil
      else
        {issue_transformation.keys.first => database_value} unless database_value.blank?
      end
    end.compact.reduce(&:merge)

    [issue, database_issue_value.select { |div| div.values.first.values.first == :custom_field }]
  end

  # [issue, custom_values] >> issue
  def add_custom_field_to_issue(issue_and_custom_fields)
    issue_and_custom_fields[0].custom_fields = issue_and_custom_fields[1].map do |template_values|
      {id: CustomField.where(name: template_values.values.first.keys.first).pluck(:id).first, value: template_values.keys.first}
    end
    issue_and_custom_fields[0]
  end

  def template_columns(spreadsheet)
    @template_columns ||= spreadsheet.row(1).map(&:downcase)
  end
end
