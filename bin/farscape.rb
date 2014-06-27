require 'farscape'
require 'optparse'
require 'pp'

#
# Binary Farscape client, it can be used for debugging
#

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: farscape [options] URL"
  options[:verb] = 'GET'

  opts.on('-x', '--verb VERB', 'Specify HTTP verb') do |verb|
    options[:verb] = verb
  end

  opts.on('-a', '--attributes', 'Show the attributes of the response') do |attr|
    options[:attributes] = attr
  end

  opts.on('-t', '--transitions', 'Show the transitions of the resource') do |attr|
    options[:transitions] = attr
  end

  opts.on('-e', '--embedded', 'Show the embedded resources of the resource') do |attr|
    options[:embedded] = attr
  end

  opts.on('-r', '--raw', 'Show the raw response as parsed by Farscape') do |raw|
    options[:raw] = raw
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end.parse!

# Take the first thing is left in the command line after taking the arguments and hope for the best
uri = ARGV.first #Addressable::URI.parse(ARGV.first)

puts "Retrieving #{uri}"

resources = Farscape.get(uri)

if options[:attributes]
  puts 'Attributes:'
  resources.properties.each_pair do |key, value|
    puts "#{key}: #{value}"
  end
end

if options[:transitions]
  puts 'Transitions:'
  resources.transitions.each do |transition|
    puts "Transition:"
    puts "Rel: #{transition.rel}"
    puts "Uri: #{transition.uri}"
    puts "Type: #{transition['type']}" if transition['type']
    puts "  "
  end
end

if options[:embedded]
  puts 'Embedded:'
  resources.embedded.each do |embedded|
    pp embedded
    puts " "
  end
end

if options[:raw]
  puts 'Raw response:'
  pp resources
end

