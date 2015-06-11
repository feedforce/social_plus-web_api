require 'rubocop/rake_task'

RuboCop::RakeTask.new do |t|
  t.options << 'lib' << 'spec'
  t.formatters = %w(simple)
end
