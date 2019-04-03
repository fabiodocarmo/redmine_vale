module RedmineWorkflowHiddenFields
	module  IssuePatch
		def self.included(base)
			base.send(:include, InstanceMethods)
			base.class_eval do
				unloadable
				alias_method_chain :safe_attribute_names, :hidden
				alias_method_chain :visible_custom_field_values, :hidden
				alias_method_chain :read_only_attribute_names, :hidden
				alias_method_chain :each_notification, :hidden

				alias_method_chain :tracker=, :hidden
				alias_method_chain :status=, :hidden
			end
		end

		module InstanceMethods

			def visible_custom_field_values_with_hidden(user=nil)
				user_real = user || User.current
				fields = visible_custom_field_values_without_hidden(user)
				fields = fields & viewable_custom_field_values(user_real)
				fields
			end


			# Returns the custom_field_values that can be viewed by the given user
			# For now: just exclude Fix Info and RNs, as it is printed seperately below description.
			def viewable_custom_field_values(user=nil)
				custom_field_values.reject do |value|
					hidden_attribute_names(user).include?(value.custom_field_id.to_s)
				end
			end


			def read_only_attribute_names_with_hidden(user=nil)
				attribute_names = read_only_attribute_names_without_hidden(user)
				attribute_names | workflow_rule_by_attribute(user).reject {|attr, rule| rule !='hidden'}.keys
			end


			# Same as above, but for hidden fields
			def hidden_attribute_names(user=nil)
				@hidden_attribute_names ||= {}
				@hidden_attribute_names[user || :nil] ||= workflow_rule_by_attribute(user).reject {|attr, rule| rule != 'hidden'}.keys
			end

			def tracker_with_hidden= (new_tracker)
				@hidden_attribute_names = {} if self.tracker != new_tracker
				self.tracker_without_hidden = new_tracker
			end

			def status_with_hidden= (new_status)
				@hidden_attribute_names = {} if self.status != new_status
				self.status_without_hidden = new_status
			end


			# Returns true if the attribute should be hidden for user
			def hidden_attribute?(name, user=nil)
				hidden_attribute_names(user).include?(name.to_s)
			end


			def each_notification_with_hidden(users, &block)
				if users.any?
					variations = users.collect {
						|user| (hidden_attribute_names(user) + (custom_field_values - visible_custom_field_values(user))).uniq
					}.uniq
					recipient_groups = Array.new(variations.count) { Array.new }
					users.each do |user|
#						recipient_groups[variations.index(hidden_attribute_names(user))] << user
						recipient_groups[variations.index(hidden_attribute_names(user) + (custom_field_values - visible_custom_field_values(user)))] << user
					end
					recipient_groups.each do |group|
						yield(group)
					end
				end
			end

			def safe_attribute_names_with_hidden(user=nil)
				names = safe_attribute_names_without_hidden(user)
				names -= hidden_attribute_names(user)
				names
			end

		end
	end
end
