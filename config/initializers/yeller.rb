#credits http://yellerapp.com/posts/2014-08-31-track-slow-queries.html

class SlowQueryLogger
  MAX_DURATION = 5 # queries that take longer than this number of seconds will be logged
  class SlowQuery < StandardError; end
  def self.initialize!
    ActiveSupport::Notifications.subscribe "start_processing.action_controller" do |name, start, finish, id, payload|
      Thread.current[:_yeller_controller] = payload[:controller]
      Thread.current[:_yeller_action]     = payload[:action]
      Thread.current[:_yeller_path]       = payload[:path]
    end

    ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
      duration = finish.to_f - start.to_f

      if duration >= MAX_DURATION
        begin
          puts "\n"+("*" * 100) + "\nWARNING SLOW QUERY" + "\n---Query: " + payload[:sql] + "\n---Controller: " + Thread.current[:_yeller_controller] + "\n---Action: " + Thread.current[:_yeller_action] + "\n---Path: " + Thread.current[:_yeller_path] + "\n---Duration: " + duration.to_s + "\n" + ("*" * 100) + "s"
        rescue Exception => ex
          puts "Exception in yeller.rb: #{ex}"
        end
       end
    end
  end
end
SlowQueryLogger.initialize!
