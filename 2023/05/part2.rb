#!/usr/bin/env ruby
require 'debug'
require_relative "./common"

# The key bit in part2 is to do Range mapping instead of individual numbers
# So within a range you know that an input range maps to an output range, but
# you need to check for the overlap on the input range against the seed/water
# etc range as you only want to map the overlap.
#

class Almanac

  def lookup(input:, source: "seed", destination: "location")
    current_map    = maps[source]
    current_inputs = [ input ]
    outputs        = []

    loop do
      outputs = current_inputs.map { |ci|
        current_map[ci]
      }.flatten.compact

      break if current_map.destination == destination

      current_map    = maps[current_map.destination]
      current_inputs = outputs
    end

    outputs
  end

  def lowest_location
    locations = seeds.map { |seed| lookup(input: seed) }.flatten
    locations.map { |loc| loc.begin }.min
  end
end

class InputParser
  attr_reader :input

  def initialize(input)
    @input = input
  end

  def parse
    Almanac.new.tap do |almanac|
      current_map = nil

      while line = input.gets do
        line.strip!

        case line
        when /^$/
          almanac.add_map(current_map) if current_map
          current_map = nil

        when /^[\d\s]+$/
          destination, source, length = line.split(/\s+/).map(&:to_i)
          current_map.map_ranges << MapRange.new(destination_range_start: destination,
                                                 source_range_start: source,
                                                 range_length: length)
        when /^seeds:/
          _seeds, *seed_pairs = line.split(/\s+/)
          seed_pairs.each_slice(2) do |start, length|
            range_begin = start.to_i
            range_end = range_begin + length.to_i
            almanac.seeds << (range_begin...range_end)
          end

        when /^[^\s]+ map:$/
          name, _map = line.split(/\s+/)
          current_map = Map.new(name)

        else
          raise ArgumentError, "line: #{line} not matched"
        end
      end

      almanac.add_map(current_map) if current_map
      current_map = nil
    end
  end
end

parser = InputParser.new(ARGF)
almanac = parser.parse

# currently at 91
puts "Lowest Location (part 2): #{almanac.lowest_location}"
# => Lowest Location (part 2): 6082852
