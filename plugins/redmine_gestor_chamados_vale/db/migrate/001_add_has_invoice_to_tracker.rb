class AddHasInvoiceToTracker < ActiveRecord::Migration
  def change
    add_column :trackers, :has_invoice, :boolean, default: false
  end
end
