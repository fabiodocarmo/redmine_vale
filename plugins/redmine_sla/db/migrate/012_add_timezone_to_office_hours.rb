class AddTimezoneToOfficeHours < ActiveRecord::Migration
  def change
    add_column :vsg_sla_office_hours, :timezone, :string, default: 0

    VsgSla::OfficeHour.reset_column_information
    VsgSla::OfficeHour.all.each do |oh|
      oh.timezone = oh.working_days.first.try(:timezone)
      oh.save!
    end

    remove_column :vsg_sla_working_days, :timezone, :string
  end
end
