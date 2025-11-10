namespace :sidekiq do
  desc "Clear all failed jobs from Sidekiq"
  task clear_failed: :environment do
    require 'sidekiq/api'
    
    retry_set = Sidekiq::RetrySet.new
    dead_set = Sidekiq::DeadSet.new
    
    retry_count = retry_set.size
    dead_count = dead_set.size
    
    retry_set.clear
    dead_set.clear
    
    puts "Cleared #{retry_count} retry jobs and #{dead_count} dead jobs"
  end
  
  desc "Clear jobs for a specific class"
  task :clear_job, [:job_class] => :environment do |_t, args|
    require 'sidekiq/api'
    
    job_class = args[:job_class]
    unless job_class
      puts "Usage: rake sidekiq:clear_job[JobClassName]"
      exit 1
    end
    
    cleared = 0
    
    # Clear from retry set
    Sidekiq::RetrySet.new.each do |job|
      if job.klass == job_class
        job.delete
        cleared += 1
      end
    end
    
    # Clear from dead set
    Sidekiq::DeadSet.new.each do |job|
      if job.klass == job_class
        job.delete
        cleared += 1
      end
    end
    
    # Clear from queues
    Sidekiq::Queue.all.each do |queue|
      queue.each do |job|
        if job.klass == job_class
          job.delete
          cleared += 1
        end
      end
    end
    
    puts "Cleared #{cleared} jobs for class #{job_class}"
  end
  
  desc "Show Sidekiq stats"
  task stats: :environment do
    require 'sidekiq/api'
    
    puts "\n=== Sidekiq Statistics ==="
    puts "Retry Set: #{Sidekiq::RetrySet.new.size} jobs"
    puts "Dead Set: #{Sidekiq::DeadSet.new.size} jobs"
    
    Sidekiq::Queue.all.each do |queue|
      puts "Queue '#{queue.name}': #{queue.size} jobs"
    end
    
    puts "\n"
  end
end

