require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |task|
  task.verbose = true
  task.ruby_opts << '-r turn/autorun'
  task.ruby_opts << '-I test'
  task.test_files = FileList['test/**/*_test.rb', 'test/**/*_spec.rb']
end

task :default => :test
