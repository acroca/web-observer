desc "Processes a batch of requests"

task :process_batch => :environment do
  Executor.process_batch
end