#!/usr/bin/env ruby
require 'bundler/inline'
require 'debug'

gemfile do
  source 'https://rubygems.org'
  gem 'pastel'
  gem 'tty-cursor'
end


Coordinate = Data.define(:row, :col) do
  def north
    Coordinate.new(row: row - 1, col: col)
  end

  def south
    Coordinate.new(row: row + 1, col: col)
  end

  def east
    Coordinate.new(row: row, col: col + 1)
  end

  def west
    Coordinate.new(row: row, col: col - 1)
  end
end


LabelMeta =  {
  '|' => { directions: [:north, :south], display: "│" },
  '-' => { directions: [:east,  :west],  display: "─" },
  'L' => { directions: [:north, :east],  display: "└" },
  'J' => { directions: [:north, :west],  display: "┘" },
  '7' => { directions: [:south, :west],  display: "┐" },
  'F' => { directions: [:south, :east],  display: "┌" },
  '.' => { directions: [],               display: " " },
  'S' => { directions: [:north, :south, :east, :west], display: "*" },
  'I' => { directions: [], display: "I" },
  'O' => { directions: [], display: "O" },
}

Connectors = {
  :east => :west,
  :west => :east,
  :north => :south,
  :south => :north
}

class Tile
  attr_reader :coordinate
  attr_reader :label
  attr_reader :outward
  attr_reader :inward
  attr_accessor :role

  def initialize(coordinate:, label:)
    @coordinate = coordinate
    @label      = label
    @outward    = LabelMeta[@label][:directions]
    @inward     = @outward.map { |c| Connectors[c] }
    @role       = nil
  end

  def meta_for_role(role)
    case role
    when :ground
      LabelMeta["."]
    when :inside
      LabelMeta["I"]
    when :outside
      LabelMeta["O"]
    else # edges and everything else
      LabelMeta[label]
    end
  end

  def display
    meta = meta_for_role(role)
    meta[:display]
  end

  def outward_coords
    outward.map{ |out_dir| coordinate.send(out_dir) }
  end

  def connected_to?(other)
    outward_coords.include?(other.coordinate) && other.outward_coords.include?(coordinate)
  end

  def ground?
    outward.empty?
  end

  def start?
    outward.size == 4
  end

  def to_s
    "#{label} #{coordinate}"
  end
end

class Ground
  attr_reader :row_count
  attr_reader :col_count

  def initialize(row_count:, col_count:)
    @row_count = row_count
    @col_count = col_count
    @grid = Array.new(row_count) { |index| Array.new(col_count) }
  end

  def fetch(coordinate)
    @grid[coordinate.row][coordinate.col]
  end

  def place(tile:)
    coordinate = tile.coordinate
    @grid[coordinate.row][coordinate.col] = tile
  end

  def to_s
    @grid.map { |row| row.map(&:display).join('') }.join("\n")
  end
end

class Walker
  attr_reader :start
  attr_reader :ground

  def initialize(ground:, start:)
    @ground = ground
    @start = start
  end

  def walk
    current_tile = start
    visited = []

    loop do
      visited << current_tile
      outward_tile = next_tile_from(tile: current_tile, visited: visited)

      # no outward tile chosen, so we must be back at the beginning
      break unless outward_tile

      current_tile = outward_tile
    end

    visited
  end

  def next_tile_from(tile:, visited:)
    tile.outward_coords.each do |coord|
      outward_tile = ground.fetch(coord)
      next if outward_tile.ground?
      next unless tile.connected_to?(outward_tile)
      next if visited.include?(outward_tile)
      return outward_tile
    end
    nil
  end
end

chars     = ARGF.readlines.map(&:strip).map(&:chars)
row_count = chars.size
col_count = chars[0].length
ground    = Ground.new(row_count: row_count, col_count: col_count)
start     = nil

chars.each.with_index do |row, row_coord|
  row.each.with_index do |label, col_coord|
    coord = Coordinate.new(row: row_coord, col: col_coord)
    tile  = Tile.new(coordinate: coord, label: label)
    start = tile if tile.start?
    ground.place(tile: tile)
  end
end

puts "Rows: #{ground.row_count}"
puts "Cols: #{ground.col_count}"
puts "Start: #{start}"
puts ground.to_s

walker = Walker.new(ground: ground, start: start)
path = walker.walk
mid_length = path.length / 2 + (path.length % 2)

puts "Mid Length: #{mid_length}"
