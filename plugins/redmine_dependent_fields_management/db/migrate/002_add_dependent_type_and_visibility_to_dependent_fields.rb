class AddDependentTypeAndVisibilityToDependentFields < ActiveRecord::Migration
  def change
    add_column :dependent_fields, :dependent_type, :string, default: :value
  end
end
