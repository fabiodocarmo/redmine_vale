module Patches
  module CustomFieldPatch
    def self.included(base) # :nodoc:
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        base.send(:include, InstanceMethods)
        has_many :custom_fields_grid_columns
        has_many :grid_columns, through: :custom_fields_grid_columns, source: "grid_column"
        accepts_nested_attributes_for :custom_fields_grid_columns, :allow_destroy => true
      end
    end

    module InstanceMethods
      def sorted_grid_columns
        @sorted_grid_columns ||= grid_columns.order('custom_fields_grid_columns.position ASC')
      end
    end
  end
end
