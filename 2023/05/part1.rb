#!/usr/bin/env ruby
require 'debug'
require_relative "./common"

class Almanac < AlmanacBase
  def lowest_location
    seeds.map { |seed| lookup(input: seed) }.min
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
          _seeds, *seed_ids = line.split(/\s+/)
          almanac.seeds = seed_ids.map(&:to_i)

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
puts "Lowest Location (part 1): #{almanac.lowest_location}"
