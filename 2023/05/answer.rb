#!/usr/bin/env ruby
require 'debug'

class MapRange
  attr_reader :destination_range, :source_range, :length

  def initialize(destination_range_start:, source_range_start:, range_length:)
    @range_length = range_length.to_i

    @destination_range_start = destination_range_start.to_i
    @destination_range_end = @destination_range_start + @range_length
    @destination_range = (@destination_range_start...@destination_range_end)

    @source_range_start = source_range_start.to_i
    @source_range_end = @source_range_start + @range_length
    @source_range = (@source_range_start...@source_range_end)
  end

  def cover?(input)
    source_range.cover?(input)
  end

  def [](input)
    if source_range.cover?(input)
      delta = input - source_range.begin
      destination_range.begin + delta
    else
      nil
    end
  end
end

class Map
  attr_reader :name, :source, :destination, :map_ranges
  def initialize(name)
    @name = name
    @source, _to, @destination = name.split("-")
    @map_ranges = []
  end

  def [](value)
    covering_range = map_ranges.find { |map_range| map_range.cover?(value) }
    if covering_range then
      covering_range[value]
    else
      value
    end
  end
end

class Almanac
  attr_accessor :seeds
  attr_accessor :maps

  def initialize
    @seeds = []
    @maps = {}
  end

  def add_map(map)
    maps[map.source] = map
  end

  def lookup(source: "seed", destination: "location", input:)
    current_map   = maps[source]
    current_input = input
    output        = nil

    loop do
      output = current_map[current_input]
      break if current_map.destination == destination

      current_map = maps[current_map.destination]
      current_input = output
    end

    output
  end

  def locations
    seeds.map { |seed| lookup(input: seed) }
  end

  def lowest_location
    locations.min
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

puts "Lowest Location: #{almanac.lowest_location}"
