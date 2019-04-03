class AddRemoveDeviationJob < ExecJob
  unloadable

  def perform(issue = Issue.new)
    issue = fetch_issue(issue)

    return unless found_issue = find_issue_in_relations(issue, [issue])

    if config[:change_found_issue].to_bool
      add_remove_deviation(found_issue)
      found_issue.status_id = config[:new_status]
      found_issue.save(validate: false)
    else
      add_remove_deviation(issue)
    end
  end

  def find_issue_in_relations(issue, tested_issues)
    related_issues = fetch_related_issue(issue, tested_issues)

    issue = select_issue_with_tracker(related_issues)

    if issue
      issue.status_id.in?(config[:search_statuses].map { |h| h['status'] }.map(&:to_i)) ? issue : nil
    else
      tested_issues |= related_issues
      related_issues.map { |i| find_issue_in_relations(i, tested_issues) }.compact.last
    end
  end

  def fetch_related_issue(issue, tested_issues)
    issue.relations
         .flat_map { |r| [r.issue_to, r.issue_from] }
         .uniq
         .reject { |i| i.in?(tested_issues) }
         .sort_by(&:created_on)
  end

  def select_issue_with_tracker(related_issues)
    issues = related_issues.select { |i| i.tracker_id == config[:tracker].to_i }

    closed_issues = issues.select { |i| i.closed? }

    closed_issues.any? ? closed_issues.last : issues.last
  end

  def add_remove_deviation(issue)
    deviations = remove_deviation(config[:remove_desviation_key], issue.custom_value_for(config[:desviation_field]))
    deviations = add_deviation(config[:add_desviation_key], deviations)

    issue.custom_field_values = {
      config[:desviation_field] => deviations
    }
  end

  def add_deviation(deviation, deviations)
    [deviation.to_s].reject(&:blank?) | deviations.map(&:to_s)
  end

  def remove_deviation(deviation, deviations)
    Array.wrap(deviations).map(&:to_s) - deviation.to_s.split(';').map(&:strip)
  end

  def self.schema
    {
      desviation_field: issue_custom_field_schema,
      add_desviation_key: string_field_schema,
      remove_desviation_key: string_field_schema,
      tracker: tracker_schema,
      new_status: status_schema,
      change_found_issue: bool_field_schema,
      search_statuses: {
        field_type: :many,
        fields: {
          status: status_schema
        }
      },
    }
  end
end
