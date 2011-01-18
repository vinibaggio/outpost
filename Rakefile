require 'rake/testtask'

desc 'Default: run tests'
task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.tests << 'test'
  t.pattern << 'test/**/*_test.rb'
  t.verbose = true
end
