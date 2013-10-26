require 'rake'
require 'rake/clean'

CLOBBER.include('.yardoc', 'yardoc')
CLOBBER.uniq!

require 'yard'
require 'yard/rake/yardoc_task'

namespace :doc do
  desc 'Generate Yardoc documentation'
  task :yard do
    YARD::Rake::YardocTask.new
  end
end
