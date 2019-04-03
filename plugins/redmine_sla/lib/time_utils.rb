class TimeUtils
  def self.compare_times(t1, t2)
    t1.strftime( "%H%M%S%N" ) <=> t2.strftime( "%H%M%S%N" )
  end

  def self.min(t1, t2)
    compare_times(t1, t2) <= 0 ? t1 : t2
  end

  def self.diff(t1, t2)
    (t1.hour - t2.hour) + (t1.min - t2.min)/60.0 + (t1.sec - t2.sec)/3600.0
  end

  def self.time_with_zone(zone, time)
    if zone
      time ? time.in_time_zone(zone) : nil
    else
      time
    end
  end
end
