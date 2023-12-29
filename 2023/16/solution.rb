#!/usr/bin/env ruby
require 'bundler/inline'
require 'debug'
require 'set'

gemfile do
  source 'https://rubygems.org'
  gem 'pastel'
  gem 'tty-cursor'
  gem 'psych', "~> 5.1"
end

COLOR = Pastel.new

Coordinate = Data.define(:row, :col) do
  def up
    Coordinate.new(row: row - 1, col: col)
  end

  def down
    Coordinate.new(row: row + 1, col: col)
  end

  def right
    Coordinate.new(row: row, col: col + 1)
  end

  def left
    Coordinate.new(row: row, col: col - 1)
  end
end

class Tile
  attr_reader :coordinate
  attr_accessor :energized

  def self.glpyh
    raise NotImplementedError
  end

  def self.for(glyph)
    @for ||= {
      '.' => Empty,
      '/' => UpMirror,
      '\\' => DownMirror,
      "|" => VerticalSplit,
      "-" => HorizontalSplit,
    }
    @for.fetch(glyph)
  end

  def initialize(row:, col:)
    @coordinate = Coordinate.new(row:, col:)
    @energized = Set.new
  end

  def energized?
    @energized.any?
  end

  def drain_energy
    @energized.clear
  end

  def activate(from_coord)
    return [] if @energized.include?(from_coord)
    @energized << from_coord
    output_coordinates(from_coord)
  end

  def glyph
    self.class.glyph
  end

  def display
    if self.energized? then
      COLOR.yellow('#')
    else
      COLOR.white(glyph)
    end
  end

  def to_s
    glyph
  end
end

class Empty < Tile
  def self.glyph
    "."
  end

  def output_coordinates(from_coord)
    case from_coord
    when coordinate.up
      [coordinate.down]

    when coordinate.down
      [coordinate.up]

    when coordinate.left
      [coordinate.right]

    when coordinate.right
      [coordinate.left]

    else
      debugger
      raise :boom
    end
  end
end

class UpMirror < Tile
  def self.glyph
    "/"
  end

  def output_coordinates(from_coord)
    case from_coord
    when coordinate.up
      [coordinate.left]
    when coordinate.down
      [coordinate.right]
    when coordinate.left
      [coordinate.up]
    when coordinate.right
      [coordinate.down]
    else
      debugger
      raise :boom
    end
  end
end

class DownMirror < Tile
  def self.glyph
    "\\"
  end

  def output_coordinates(from_coord)
    case from_coord
    when coordinate.up
      [coordinate.right]
    when coordinate.down
      [coordinate.left]
    when coordinate.left
      [coordinate.down]
    when coordinate.right
      [coordinate.up]
    else
      debugger
      raise :boom
    end
  end
end

class VerticalSplit < Tile
  def self.glyph
    "|"
  end

  def output_coordinates(from_coord)
    case from_coord
    when coordinate.up
      [coordinate.down]

    when coordinate.down
      [coordinate.up]

    when coordinate.left
      [coordinate.up, coordinate.down]

    when coordinate.right
      [coordinate.up, coordinate.down]
    else
      debugger
      raise :boom
    end
  end
end

class HorizontalSplit < Tile
  def self.glyph
    "-"
  end

  def output_coordinates(from_coord)
    case from_coord
    when coordinate.up
      [coordinate.left, coordinate.right]

    when coordinate.down
      [coordinate.left, coordinate.right]

    when coordinate.left
      [coordinate.right]

    when coordinate.right
      [coordinate.left]
    else
      debugger
      raise :boom
    end
  end
end

Action = Data.define(:from_coord, :tile)

class Grid
  attr_reader :col_count
  attr_reader :row_count

  def initialize(lines)
    @lines = lines.map(&:strip)
    @tiles = generate_tiles(@lines)
    @row_count = @tiles.size
    @col_count = @tiles.first.size
  end

  def [](row)
    @tiles[row]
  end


  def drain_energy
    @tiles.map { |row| row.map(&:drain_energy) }
  end

  def fetch(coord)
    raise KeyError, "Out of bounds #{coord}" unless in_bounds?(coord)
    @tiles[coord.row][coord.col]
  end

  def fetch_row(row)
    @tiles[row]
  end

  def fetch_col(col)
    @tiles.map { |r| r[col] }
  end

  def to_s
    @tiles.map{ |r| r.join('') }.join("\n")
  end

  def to_display
    @tiles.map { |row| row.map(&:display).join('') }.join("\n")
  end

  def energized_count
    @tiles.flatten.count { |t| t.energized? }
  end

  def in_bounds?(coord)
    return false unless (0...@row_count).cover?(coord.row)
    return false unless (0...@col_count).cover?(coord.col)
    return true
  end

  private

  def generate_tiles(lines)
    t = Array.new(lines.length) { |r| r = Array.new(lines.first.length) }

    lines.each.with_index do |row, row_coord|
      row.chars.each.with_index do |glyph, col_coord|
        klass = Tile.for(glyph)
        t[row_coord][col_coord] = klass.new(row: row_coord, col: col_coord)
      end
    end

    t
  end
end

class Walker
  attr_reader :grid
  attr_reader :start

  def initialize(grid:)
    @grid = grid
  end

  def traverse(start: Coordinate.new(row: 0, col: 0), from: :left)
    start = start
    start_tile = grid.fetch(start)
    action = Action.new(tile: start_tile, from_coord: start.send(from))
    actions = [ action ]

    while action = actions.shift do
      tile = action.tile
      #puts "Activating #{tile} from #{action.from_coord}: "
      tile.activate(action.from_coord).each do |next_coord|
        next unless grid.in_bounds?(next_coord)
        actions << Action.new(tile: grid.fetch(next_coord), from_coord: tile.coordinate)
      end
      #puts grid.to_display
      #puts
    end
  end
end


lines = ARGF.readlines
grid = Grid.new(lines)
walker = Walker.new(grid: grid)

max_energy = 0
max_location = nil

[ [ :up, grid.fetch_row(0) ],
  [ :left, grid.fetch_col(0) ],
  [ :right, grid.fetch_row(-1) ],
  [ :down, grid.fetch_col(-1) ]
].each do | from, start_tiles |
  start_tiles.each do |start_tile|
    grid.drain_energy
    raise :boom unless grid.energized_count == 0
    start = start_tile.coordinate
    walker.traverse(start:, from:)
    energy = grid.energized_count
    if energy > max_energy then
      max_energy = energy
      max_location = start
      puts "Current max -> start: #{start} from: #{from} energy: #{energy}"
    end
  end
end

puts max_energy
