# encoding: UTF-8

module DependentFieldsManagement
  module IssuePatch

    def self.included(base) # :nodoc
      base.send(:include, InstanceMethods)

      # Same as typing in the class
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in developmen
        validate :validate_dependent_fields_by_tracker_project

        alias_method_chain :required_attribute?, :dependent
        alias_method_chain :read_only_attribute_names, :dependent

        alias_method 'safe_attributes=', 'safe_attributes_with_dependent='

        alias_method_chain 'tracker=', 'dependent'
        alias_method_chain 'tracker_id=', 'dependent'
        alias_method_chain 'project=', 'dependent'
        alias_method_chain 'project_id=', 'dependent'
        alias_method_chain 'status=', 'dependent'
        alias_method_chain 'status_id=', 'dependent'
      end
    end

    module InstanceMethods

      def fields_visibility_dependency_rules
        @fields_visibility_dependency_rules ||= DependentField.where(avaliable: true)
                                          .where(project_id: self.project_id)
                                          .where(tracker_id: self.tracker_id)
                                          .where(dependent_type: 'visibility')
      end

      def tracker_with_dependent=(value)
        self.tracker_without_dependent = value
        clear_memoized_rules
      end

      def tracker_id_with_dependent=(value)
        self.tracker_id_without_dependent = value
        clear_memoized_rules
      end

      def project_with_dependent=(value, keep_tracker=false)
        self.send(:project_without_dependent=, value, keep_tracker)
        clear_memoized_rules
      end

      def project_id_with_dependent=(value)
        self.project_id_without_dependent = value
        clear_memoized_rules
      end

      def status_with_dependent=(value)
        self.status_without_dependent = value
        clear_memoized_rules
      end

      def status_id_with_dependent=(value)
        self.status_id_without_dependent = value
        clear_memoized_rules
      end

      def clear_memoized_rules
        @fields_visibility_dependency_rules = nil
        @dependent_fields = nil
      end

      def required_attribute_with_dependent?(name, user=nil)
        required_attribute_without_dependent?(name, user) || required_secondary_fields.include?(name.to_i)
      end

      def required_secondary_fields
        @dependent_fields ||= DependentField.where(avaliable: true)
                                          .where(project_id: self.project_id)
                                          .where(tracker_id: self.tracker_id)
                                          .where(dependent_type: 'value')
                                          .where(not_nullable: true)
                                          .where(DependentField.main_custom_value_condition(self.custom_field_values))
                                          .pluck(:secondary_field_id).map(&:to_i)
      end

      def read_only_attribute_names_with_dependent(user = nil)
        read_only_attributes = read_only_attribute_names_without_dependent(user)
        read_only_attributes - visible_fields_by_dependent(user, read_only_attributes, custom_field_values).map(&:custom_field_id).map(&:to_s)
      end

      def visible_fields_by_dependent(user = nil, read_only_attributes = [], visible_custom_fields)
        return [] if visible_custom_fields.empty?

        use_custom_field_where = ''

        satisfied_dependency_rules = fields_visibility_dependency_rules.select do |rule|
          main_field = visible_custom_fields.detect { |cv| cv.custom_field_id == rule.main_field_id }
          main_field && Array.wrap(main_field.value).include?(rule.main_field_value)
        end

        custom_fields_ids = satisfied_dependency_rules.map(&:secondary_field_id)

        custom_fields = CustomField.where(id: custom_fields_ids)
        values = custom_field_values.select { |value| custom_fields.include?(value.custom_field) }
        values | visible_fields_by_dependent(user, read_only_attributes - values.map(&:custom_field_id).map(&:to_s), values)
      end

      def visible_fields_by_dependent_using_attr(attr=[])
        use_custom_field_where = ''
        attr.each do |k,v|
          if v.is_a? Array
            use_custom_field_where += ActiveRecord::Base.send(:sanitize_sql_array, ['(main_field_id = ? and main_field_value in (?)) or ', k, v])
          else
            use_custom_field_where += ActiveRecord::Base.send(:sanitize_sql_array, ['(main_field_id = ? and main_field_value = ?) or ', k, v.to_s])
          end
        end

        use_custom_field_where += '1 = 2'

        custom_fields_ids = DependentField.where("project_id = ? and tracker_id = ? and dependent_type = 'visibility' AND avaliable = true", project_id, tracker_id)
                                          .where(use_custom_field_where)
                                          .select('secondary_field_id')

        custom_fields = CustomField.where(id: custom_fields_ids)

        attr.select { |k,v| custom_fields.map(&:id).map(&:to_s).include?(k.to_s) }
      end

      # Safely sets attributes
      # Should be called from controllers instead of #attributes=
      # attr_accessible is too rough because we still want things like
      # Issue.new(:project => foo) to work
      def safe_attributes_with_dependent=(attrs, user=User.current)
        return unless attrs.is_a?(Hash)

        attrs = attrs.deep_dup

        # Project and Tracker must be set before since new_statuses_allowed_to depends on it.
        if (p = attrs.delete('project_id')) && safe_attribute?('project_id')
          if allowed_target_projects(user).where(:id => p.to_i).exists?
            self.project_id = p
          end

          if project_id_changed? && attrs['category_id'].to_s == category_id_was.to_s
            # Discard submitted category on previous project
            attrs.delete('category_id')
          end
        end

        if (t = attrs.delete('tracker_id')) && safe_attribute?('tracker_id')
          if allowed_target_trackers(user).where(:id => t.to_i).exists?
            self.tracker_id = t
          end
        end
        if Redmine::VERSION::MAJOR >= 3
          if project
            # Set a default tracker to accept custom field values
            # even if tracker is not specified
            self.tracker ||= allowed_target_trackers(user).first
          end
        end

        statuses_allowed = new_statuses_allowed_to(user)
        if (s = attrs.delete('status_id')) && safe_attribute?('status_id')
          if statuses_allowed.collect(&:id).include?(s.to_i)
            self.status_id = s
          end
        end
        if new_record? && !statuses_allowed.include?(status)
          self.status = statuses_allowed.first || default_status
        end
        if (u = attrs.delete('assigned_to_id')) && safe_attribute?('assigned_to_id')
          if u.blank?
            self.assigned_to_id = nil
          else
            u = u.to_i
            if assignable_users.any?{|assignable_user| assignable_user.id == u}
              self.assigned_to_id = u
            end
          end
        end


        attrs = delete_unsafe_attributes(attrs, user)
        return if attrs.empty?

        if Redmine::VERSION::MAJOR < 3
          unless leaf?
            attrs.reject! {|k,v| %w(priority_id done_ratio start_date due_date estimated_hours).include?(k)}
          end
        end

        if attrs['parent_issue_id'].present?
          s = attrs['parent_issue_id'].to_s
          unless (m = s.match(%r{\A#?(\d+)\z})) && (m[1] == parent_id.to_s || Issue.visible(user).exists?(m[1]))
            @invalid_parent_issue_id = attrs.delete('parent_issue_id')
          end
        end

        if attrs['custom_field_values'].present?
          editable_custom_field_ids = editable_custom_field_values(user).map {|v| v.custom_field_id.to_s}
          editable_custom_field_ids.concat(visible_fields_by_dependent_using_attr(attrs['custom_field_values']).keys)

          attrs['custom_field_values'].select! {|k, v| editable_custom_field_ids.include?(k.to_s)}
        end

        if attrs['custom_fields'].present?
          editable_custom_field_ids = editable_custom_field_values(user).map {|v| v.custom_field_id.to_s}
          attrs['custom_fields'].select! {|c| editable_custom_field_ids.include?(c['id'].to_s)}
        end

        # mass-assignment security bypass
        assign_attributes attrs, :without_protection => true
      end

      def validate_dependent_fields_by_tracker_project
        return unless project && tracker

        dependent_fields = DependentField.available.value_rules
            .by_tracker_id_and_project_id_and_main_field_ids(tracker_id, project_id, available_custom_fields.map(&:id))

        dependent_fields.each do |dependent_field|
          # se o campo A está vazio no formulário não precisa de análise do campo B
          next if (custom_field_value(dependent_field.main_field).blank?)

          # o campo B deve estar sempre preenchido com qualquer valor
          if (dependent_field.secondary_field_value.nil? || dependent_field.secondary_field_value == '')

            # independente do valor de A
            if (dependent_field.main_field_value.nil? || dependent_field.main_field_value == '')
              if (custom_field_value(dependent_field.secondary_field).blank?)
                errors.add(dependent_field.secondary_field.name, I18n.t('activerecord.errors.messages.empty'))
              end
            # para um valor específico de A
            else
              if custom_field_value(dependent_field.main_field) == dependent_field.main_field_value && dependent_field.secondary_field && custom_field_value(dependent_field.secondary_field).blank?
                errors.add(dependent_field.secondary_field.name, I18n.t('activerecord.errors.messages.empty'))
              end
            end

          # o campo B deve estar preenchido com determinado valor
          else
            secondary_field_values_list = []
            secondary_field_values_list = dependent_field.secondary_field_value.split(/; */)

            # independente do valor de A
            if (dependent_field.main_field_value.nil? || dependent_field.main_field_value == '')
              if !custom_field_value(dependent_field.secondary_field).blank? && !(secondary_field_values_list.include? custom_field_value(dependent_field.secondary_field))
                errors.add(dependent_field.secondary_field.name, I18n.t('activerecord.errors.messages.invalid'))
              end
            # para um valor específico de A
            else
              if (custom_field_value(dependent_field.main_field) == dependent_field.main_field_value)
                if !custom_field_value(dependent_field.secondary_field).blank? && !(secondary_field_values_list.include? custom_field_value(dependent_field.secondary_field))
                  errors.add(dependent_field.secondary_field.name, I18n.t('activerecord.errors.messages.invalid'))
                end
              end
            end

          end #if/else
        end #for each
      end # function

      def validate_not_nullable_fields_by_tracker
        custom_fields = self.available_custom_fields
        custom_fields_id = [];
        custom_fields.each do |custom_field|
          custom_fields_id << custom_field.id
        end

        dependent_fields = DependentField.where("tracker_id = ? AND project_id = ? AND main_field_id in (?) AND not_nullable = true AND avaliable = true AND dependent_type = 'value'", self.tracker.id, self.project.id, custom_fields_id).all

        dependent_fields.each do |dependent_field|
          next if custom_field_value(dependent_field.main_field).blank?
          next unless custom_field_value(dependent_field.secondary_field).blank?
          errors.add(dependent_field.secondary_field.name, I18n.t('activerecord.errors.messages.empty'))
        end
      end

      def validate_not_nullable_fields_by_tracker_depends_on_especific_value
        custom_fields = self.available_custom_fields
        custom_fields_id = []
        custom_fields.each do |custom_field|
          custom_fields_id << custom_field.id
        end

        dependent_fields = DependentField.where("tracker_id = ? AND project_id = ? AND main_field_id in (?) AND not_nullable = false AND avaliable = true AND dependent_type = 'value'", self.tracker.id, self.project.id, custom_fields_id).all

        dependent_fields.each do |dependent_field|
          next if (custom_field_value(dependent_field.main_field) != dependent_field.main_field_value)
          next unless custom_field_value(dependent_field.secondary_field).blank?
          errors.add(dependent_field.secondary_field.name, I18n.t('activerecord.errors.messages.empty'))
        end
      end

    end
  end
end
