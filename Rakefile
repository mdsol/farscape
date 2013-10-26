lib_dir = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib_dir)
$LOAD_PATH.uniq!

require 'rubygems'
require 'rake'
require 'dice_bag/tasks'
require 'farscape'

Dir['tasks/**/*.rake'].each { |rake| load rake }
