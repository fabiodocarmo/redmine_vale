class AddKeyToCustomFieldEnumeration < ActiveRecord::Migration
  def change
    add_column :custom_field_enumerations, :key, :string
    add_index  :custom_field_enumerations, :key
  end
end
