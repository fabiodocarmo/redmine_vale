class VsgSla::OfficeHour < VsgSla
  unloadable

  attr_protected :name, :working_days_attributes, as: :admin

  has_many :working_days, dependent: :destroy
  has_many :slas        , dependent: :destroy

  accepts_nested_attributes_for :working_days, reject_if: :all_blank, allow_destroy: true
end
