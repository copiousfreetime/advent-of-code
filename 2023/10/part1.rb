#!/usr/bin/env ruby

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

LabelConnections = {
  '|' => [:north, :south],
  '-' => [:east, :west],
  'L' => [:north, :east],
  'J' => [:north, :west],
  '7' => [:south, :west],
  'F' => [:south, :east],
  '.' => [],
  'S' => [:start]
}

class Tile
  attr_reader :connections
  attr_reader :coordinate
  attr_reader :label
  def initialize(coordinate:, label:)
    @coordinate = coordinate
    @label = label
    @connections = LabelConnections[@label]
  end

  def ground?
    @connections.empty?
  end

  def start?
    @connections.include?(:start)
  end

  def has_north?
    @connections.include?(:north)
  end

  def has_east?
    @connections.include?(:east)
  end

  def has_south?
    @connections.include?(:south)
  end

  def has_west?
    @connections.include?(:west)
  end
end

class Ground
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
    @grid.map { |row| row.map(&:label).join('') }.join("\n")
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

puts ground.to_s
