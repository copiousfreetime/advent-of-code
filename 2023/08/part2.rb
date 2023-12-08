#!/usr/bin/env ruby
require 'debug'

# Load input
input      = ARGF.readlines.map(&:strip)

# parse directions into array
DIRECTIONS = input[0].split(//).compact

# createa regex to match the node lines
MATCHER = /\A(?<label>\w+)\s+=\s+\((?<L>\w+),\s(?<R>\w+)\)\Z/

# load the node lines into a hash via named captures in the regex
NODE_LIST = input[2..-1].map do |encoded|
  match = MATCHER.match(encoded)
  match.named_captures
end

# convert the named captures into a hash of
# { "FGF" => { "L" => "HTC", "R" => "DTX" } }
NODE_HASH = {}.tap do |h|
  NODE_LIST.each do |node|
    h[node['label']] = node
  end
end

START       = "A"
FINISH      = "Z"
START_NODES = NODE_LIST.select { |n| n["label"].end_with?(START) }

puts "Starting node count: #{START_NODES.size}"

# so we don't have to iterator for a long time, we want to find each starting
# nodes z-cycle time. Going to assume that they all have a cycle, so go through
# each one, finding its 1st Z, and then seeing how long it gets to its 2nd Z
def z_cycle_count(node)
  current_node = node

  count = 0
  DIRECTIONS.cycle do |p|
    next_label = current_node[p]
#    puts "#{p} => #{next_label} : #{count}"
    count     += 1
    break if next_label.end_with?(FINISH)
    current_node = NODE_HASH[next_label]
  end

  return count
end

# brute force factoring
def factors_of(number)
  limit = number / 2
  [ number ].tap do |factors|
    (2..limit).select do |attempt|
      if (number % attempt).zero? then
        factors << attempt
      end
    end
  end
end

results = {}
lcm = nil
gcm = 1

START_NODES.each do |node|
  count = z_cycle_count(node)
  factors = factors_of(count)
  gcm = gcm * count

  results[node['label']] = {
    count: count,
    factors: factors,
  }

  if lcm.nil? then
    lcm = factors
  else
    lcm = lcm & factors
    puts lcm
  end
end

# and now find the least common multiple of the counts
pp results
count = nil
if lcm.empty? then
  count = gcm
else
  count = lcm.sort.first
end
#puts "Count: #{count_hash.values.reduce(:*)}"
puts "Count: #{count}"
