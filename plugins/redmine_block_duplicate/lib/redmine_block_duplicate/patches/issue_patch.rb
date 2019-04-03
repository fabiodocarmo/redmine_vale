# This file is a part of Redmine CRM (redmine_contacts) plugin,
# customer relationship management plugin for Redmine
#
# Copyright (C) 2011-2014 Kirill Bezrukov
# http://www.redminecrm.com/
#
# redmine_contacts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_contacts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_contacts.  If not, see <http://www.gnu.org/licenses/>.

module RedmineBlockDuplicate
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          validate :duplicity, on: :create
        end
      end

      module InstanceMethods
        def duplicity
          BlockDuplicate.all.select { |bd|
            (project_id.to_s.in? bd.project_id) && (tracker_id.to_s.in? bd.tracker_id)
          }.each do |bd|
            if bd.copy_flag && !@copied_from.nil?
              verify_copied_from_custom_fields(self,bd)
            else
              duplicates = bd.find_issues_duplicated_by(self)
              if duplicates == 'valores_duplicados'
                for required_field in bd.custom_fields do
                  dup_field = CustomField.find(required_field.to_i)
                  errors[:base] << l(:verify_multiple_value, custom_field: dup_field.name)
                end
              elsif duplicates.length > 0
                errors[:base] << l(:duplicated_issue_alert, issues: duplicates.map { |id| "##{id}" }.join(', '), authors: duplicates.map {|id| Issue.find(id).author.login}.join(', '))
                for required_field in bd.custom_fields do
                  dup_field = CustomField.find(required_field.to_i)
                  errors[:base] << l(:check_duplicated_field, custom_field: dup_field.name)
                end
              end
              return
            end
          end
        end

        def verify_copied_from_custom_fields(issue,block_duplicate)
          parent_issue = @copied_from
          x = 0
          different_counter = 0
          while x < block_duplicate.custom_fields.length
            if !issue.custom_field_value(block_duplicate.custom_fields[x]).nil?
              if issue.custom_field_value(block_duplicate.custom_fields[x]) != parent_issue.custom_field_value(block_duplicate.custom_fields[x])
                different_counter += 1
              end
            end
            x += 1
          end
          if different_counter > 0
            for required_field in block_duplicate.custom_fields do
              diff_field = custom_field_values.detect {|v| v.custom_field_id == required_field.to_i}
              errors[:base] << l(:custom_field_different_from_parent, custom_field: diff_field.custom_field.name)
            end
            return
          end
        end
      end
    end
  end
end
