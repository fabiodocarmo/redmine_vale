class AddListAutoCompleteOptions < ActiveRecord::Migration
  def change
    create_table "improvecf_autocomplete_options", :force => true do |t|
      t.column "custom_field_id", :integer, :null => false
      t.column "value", :string, :null => false
    end

    add_index "improvecf_autocomplete_options", ["custom_field_id"], :name => "imprcf_autocomp_cf_id"
  end
end
