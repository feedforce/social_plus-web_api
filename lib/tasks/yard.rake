require 'yard'
require 'yard/rake/yardoc_task'

YARD::Rake::YardocTask.new do |t|
  t.files = %w(lib/**/*.rb)
  t.options += %w(--markup markdown)
  t.options += %w(--debug --verbose) if $trace
end
