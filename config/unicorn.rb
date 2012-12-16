
worker_processes 3 # amount of unicorn workers to spin up
timeout 30         # restarts workers that hang for 30 seconds

preload_app true
@resque_pid = nil

before_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

  # If you are using Redis but not Resque, change this
  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info('Disconnected from Redis')
  end


  sleep 1
end

after_fork do |server, worker|
  # Replace with MongoDB or whatever
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  @resque_pid ||= spawn("bundle exec rake " + \
    "resque:work QUEUES=*")
  # If you are using Redis but not Resque, change this
  #if defined?(Resque)
    #Resque.redis = ENV['REDIS_URI']
   # Rails.logger.info('Connected to Redis')
  #end
end
