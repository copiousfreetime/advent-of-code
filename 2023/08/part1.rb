#!/usr/bin/env ruby
require 'debug'

# Load input
input      = ARGF.readlines.map(&:strip)

# parse directions into array
directions = input[0].split(//).compact

# createa regex to match the node lines
regex      = /\A(?<label>\w+)\s+=\s+\((?<L>\w+),\s(?<R>\w+)\)\Z/

# load the node lines into a hash via named captures in the regex
node_list  = input[2..-1].map do |encoded|
  match = regex.match(encoded)
  match.named_captures
end

# convert the named captures into a hash of
# { "FGF" => { "L" => "HTC", "R" => "DTX" } }
node_hash = {}.tap do |h|
  node_list.each do |node_info|
    label = node_info.delete('label')
    h[label] = node_info
  end
end

start        = "AAA"
finish       = "ZZZ"
count        = 0
current_node = node_hash[start]

directions.cycle do |p|
  next_label = current_node[p]
  puts "#{p} => #{next_label} : #{count}"
  count     += 1
  break if next_label == finish
  current_node = node_hash[next_label]
end

puts "Count: #{count}"
