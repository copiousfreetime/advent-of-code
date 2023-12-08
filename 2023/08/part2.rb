#!/usr/bin/env ruby
require 'debug'

# Load input
input = ARGF.readlines.map(&:strip)
width = 23

# parse directions into array
DIRECTIONS = input[0].split(//).compact
puts "#{"Directions".ljust(width)}: #{DIRECTIONS.length}"

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

puts "#{"Starting node count".ljust(width)}: #{START_NODES.size}"

# so we don't have to iterate for a long time, we want to find each starting
# nodes cycle time. Going to assume that they all have a cycle, and it repeats
# with the same length starting from the beginning
def z_cycle_count(node)
  current_node = node

  count = 0
  DIRECTIONS.cycle do |p|
    next_label = current_node[p]
    count     += 1
    break if next_label.end_with?(FINISH)
    current_node = NODE_HASH[next_label]
  end

  return count
end

# brute force factoring, do not include 1 and self
def factors_of(number)
  limit = number / 2
  [ ].tap do |factors|
    (2..limit).select do |attempt|
      if (number % attempt).zero? then
        factors << attempt
      end
    end
  end
end

results = {}
least_common_multiples = []

START_NODES.each do |node|
  count = z_cycle_count(node)
  factors = factors_of(count)

  results[node['label']] = {
    count: count,
    factors: factors,
  }

  least_common_multiples |= factors
end

puts "#{"Least Common Multiples".ljust(width)}: #{least_common_multiples}"
puts "#{"Steps".ljust(width)}: #{least_common_multiples.reduce(:*)}"
