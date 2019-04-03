class VsgSla::WorkingDay < VsgSla
  unloadable
  belongs_to :office_hour

  WEEK_DAY = [
    :sunday,
    :monday,
    :tuesday,
    :wednesday,
    :thursday,
    :friday,
    :saturday
  ]
end
