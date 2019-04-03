web: bundle exec puma

job: bundle exec sidekiq -C config/sidekiq.yml

job-elastic-search: bundle exec rake resque:workers COUNT=5 QUEUE=*

