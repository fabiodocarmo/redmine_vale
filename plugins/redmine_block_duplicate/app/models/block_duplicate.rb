class BlockDuplicate < ActiveRecord::Base
  unloadable

  attr_protected :project_id, :tracker_id, :copy_flag, :custom_fields, :statuses, as: :admin

  serialize :custom_fields, Array
  serialize :statuses, Array
  serialize :project_id, Array
  serialize :tracker_id, Array

  belongs_to :project
  belongs_to :tracker

  before_validation :compact_custom_fields, :compact_statuses, :compact_project_id, :compact_tracker_id

  validates :project_id, :tracker_id, :custom_fields, presence: true

  def find_project_id
    Project.sorted.where(id: project_id)
  end

  def find_tracker_id
    Tracker.sorted.where(id: tracker_id)
  end

  def find_custom_fields
    IssueCustomField.sorted.where(id: custom_fields)
  end

  def find_statuses
    IssueStatus.sorted.where(id: statuses)
  end

  def get_join_custom_fields_without_grid
    join_custom_value = custom_fields.map do |cf|
      "JOIN custom_values cv#{cf}
        ON cv#{cf}.customized_id = issues.id
        AND cv#{cf}.custom_field_id = #{cf}
        AND cv#{cf}.customized_type = 'Issue'"
    end.join(" ")
    join_custom_value
  end

  def get_join_custom_fields_with_grid
    join_grid_value = custom_fields.map do |cf|
      "JOIN custom_values cv_grid#{cf}
        ON cv_grid#{cf}.customized_id = issues.id
        AND cv_grid#{cf}.customized_type = 'Issue'
      JOIN custom_fields cfields#{cf}
        ON cfields#{cf}.id = cv_grid#{cf}.custom_field_id
        AND cfields#{cf}.field_format = 'grid'
      JOIN grid_values cv#{cf}
        ON cv#{cf}.custom_value_id = cv_grid#{cf}.id
        AND cv#{cf}.column = #{cf}"
    end.join(" ")
    join_grid_value
  end

  def find_issues_duplicated_by(issue)
    join_custom_value = get_join_custom_fields_without_grid
    join_grid_value = get_join_custom_fields_with_grid

    where_filter = {project_id: project_id, tracker_id: tracker_id}
    where_fields = {}

    custom_fields.each do |cf|
      if issue.custom_field_value(cf)
        where_fields["cv#{cf}".to_sym] = [issue.custom_field_value(cf)]
      end
    end


    grid_custom_fields = issue.custom_field_values.select { |custom_field_value|
      custom_field_value.custom_field.field_format == 'grid' &&
      custom_field_value.value.to_s.gsub('=>',':').present?
    }.select{ |grid_field_value|
      grid_field_value.custom_field.grid_columns.select{|cf| cf.id.to_s.in? custom_fields}.any?
    }.map { |grid_field_value|
      JSON.parse(issue.custom_field_value(grid_field_value.custom_field.id).to_s.gsub('=>',':'))
    }.each{ |grid_hash|
      custom_fields.each{ |cf|
        grid_hash.each{ |_row,columns|
          if cell_value = columns[cf]
            if !where_fields["cv#{cf}".to_sym]
              where_fields["cv#{cf}".to_sym] = []
            end
            where_fields["cv#{cf}".to_sym] << cell_value
          end
        }
      }
    }

    if (where_fields.any?{ |_cf,values| values.uniq.length < values.length})
      return 'valores_duplicados'
    end


    if where_fields.present?
      inside_where_cv = where_fields.reject{|cv,values|
        values.empty?
      }.map { |cv,values|
        v = values.map{|value| "'#{value}'"}
        h = values.map{|value| "'#{Digest::SHA256.hexdigest(value)}'"}
        "#{cv}.value_hashed in (#{h.join(", ")}) and #{cv}.value in (#{v.join(", ")})"
      }

      inside_where_gv = where_fields.reject{|cv,values|
        values.empty?
      }.map { |cv,values|
        v = values.map{|value| "'#{value}'"}
        "#{cv}.value in (#{v.join(", ")})"
      }

      where_custom_values = "("+ inside_where_cv.join(" AND ")+")"
      where_grid_values = "("+ inside_where_gv.join(" AND ")+")"

      search_for_custom_values = Issue.joins(join_custom_value).where(where_filter).where(where_custom_values).limit(1)
      search_for_grid_values = Issue.joins(join_grid_value).where(where_filter).where(where_grid_values).limit(1)

      if statuses.present?
        search_for_custom_values = search_for_custom_values.where(status_id: statuses)
        search_for_grid_values = search_for_grid_values.where(status_id: statuses)
      end

      search_for_duplicates = Array.new

      if search_for_custom_values[0].present?
        search_for_duplicates << search_for_custom_values[0]
      elsif search_for_grid_values[0].present?
        search_for_duplicates << search_for_grid_values[0]
      end

    else
        search_for_duplicates = []
    end
    search_for_duplicates
  end

  private

  def compact_custom_fields
    custom_fields.reject! { |a| a.blank? }
  end

  def compact_statuses
    statuses.reject! { |a| a.blank? }
  end

  def compact_project_id
    project_id.reject! { |a| a.blank? }
  end

  def compact_tracker_id
    tracker_id.reject! { |a| a.blank? }
  end

end
