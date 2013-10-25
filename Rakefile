require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |task|
  task.ruby_opts << '-Itest'
  task.ruby_opts << '-r minitest/autorun'
  task.test_files = FileList['test/**/*_test.rb', 'test/**/*_spec.rb']
end

task :default => :test
