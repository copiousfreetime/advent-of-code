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
    case input
    when Numeric
      lookup_numeric(input)
    when Range
      lookup_range(input)
    end
  end

  def lookup_numeric(input)
    if source_range.cover?(input)
      delta = input - source_range.begin
      destination_range.begin + delta
    else
      input
    end
  end

  def lookup_range(input)
    if overlap?(input) then
      overlap_begin = [input.begin, source_range.begin].max
      overlap_end   = [input.end, source_range.end].min
      output_begin  = lookup_numeric(overlap_begin)
      output_end    = lookup_numeric(overlap_end)
      (output_begin...output_end)
    else
      input
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

  def [](input)
    case input
    when Numeric
      lookup_number(input)
    when Range
      lookup_range(input)
    end
  end

  def lookup_number(input)
    covering_range = map_ranges.find { |map_range| map_range.cover?(input) }
    value = if covering_range then
      covering_range[input]
    else
      input
    end
    value
  end

  def lookup_range(input)
    covering_range = map_ranges.find { |map_range| map_range.cover?(input) }
    if covering_range then
      covering_range[input].begin
    else
      raise ArgumentError, "Map#lookup: #{input} not covered by a single range"
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

  def lowest_location
    seeds.map { |seed| lookup(input: seed) }.min
  end
end
