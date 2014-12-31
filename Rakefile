require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new
task default: :spec

YARD::Rake::YardocTask.new do |t|
  t.files   = %w(lib/**/*.rb)
  t.options = []
  t.options << '--debug' << '--verbose' if $trace
  t.options << '--markup' << 'markdown'
end

RuboCop::RakeTask.new do |t|
  t.options << 'lib' << 'spec'
end
