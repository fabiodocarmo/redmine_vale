module RedmineSla
  module Modules
    module SlaModule
      def self.included(base) # :nodoc
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in developmen

          has_and_belongs_to_many :vsg_sla_slas, class_name: 'VsgSla::Sla'
          before_destroy :destroy_sla
        end
      end

      module ClassMethods; end

      module InstanceMethods
        def destroy_sla
          vsg_sla_slas.clear
        end
      end
    end
  end
end
