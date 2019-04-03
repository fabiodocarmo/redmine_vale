class AddBigSizeToValueAutocomplete < ActiveRecord::Migration
  def change
    change_column :improvecf_autocomplete_options, :value, :string, :limit => 1024, :default => '', :null => false
  end
end
