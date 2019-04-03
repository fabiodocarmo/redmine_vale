# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { 5 }.to_i
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
@environment = ENV.fetch("RAILS_ENV") { "development" } # It won't read '-e' option
                                                        # in command such as 
                                                        # bundle exec puma -e production
environment @environment

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
web_concurrency = ENV.fetch("WEB_CONCURRENCY") { 1 }.to_i
workers web_concurrency

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
preload_app! if @environment == 'production' && web_concurrency > 1

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
#
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

worker_killer_max_ram = ENV.fetch("WORKER_KILLER_MAX_RAM") { "0" }.to_i

if worker_killer_max_ram > 0 && web_concurrency > 1 && @environment == 'production'
  before_fork do
    require 'puma_worker_killer'
  
    PumaWorkerKiller.config do |config|
      config.ram           = worker_killer_max_ram # MB
      config.frequency     = ENV.fetch("WORKER_KILLER_FREQUENCY") { 5 }.to_i # seconds
      config.percent_usage = ENV.fetch("WORKER_KILLER_PERCENT_USAGE") { 0.9 }.to_f # %
      config.rolling_restart_frequency = ENV.fetch("WORKER_ROLLING_RESTART_FREQUENCY") { 6 * 3600 }.to_i # 6 hours in seconds - default
    end
    PumaWorkerKiller.start
  end
end
