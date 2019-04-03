# redmine_sla

## How to install notify mail
1. bundle install
2. rails g delayed_job:active_record
3. rake db:migrate
4. Add to environments
```rb
config.active_job.queue_adapter = :delayed_job
```
5. Created conf/initializers/delayed_job.rb
```rb
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
```
6. bin/delayed_job --queue=sla -n 3 start
