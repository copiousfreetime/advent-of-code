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

pastel = Pastel.new

LabelMeta =  {
  '|' => { directions: [:north, :south], vertex: :toggle, display: pastel.green("│") },
  '-' => { directions: [:east,  :west],  vertex: 0, display: pastel.green("─") },
  'L' => { directions: [:north, :east],  vertex: -1, display: pastel.green("└") },
  'J' => { directions: [:north, :west],  vertex: 1, display: pastel.green("┘") },
  '7' => { directions: [:south, :west],  vertex: -1, display: pastel.green("┐") },
  'F' => { directions: [:south, :east],  vertex: 1, display: pastel.green("┌") },
  '.' => { directions: [],               vertex: 0, display: pastel.black(" ") },
  'S' => { directions: [:north, :south, :east, :west], vertex: nil, display: pastel.yellow("*") },
  'I' => { directions: [], vertex: 0, display: pastel.red("I") },
  'O' => { directions: [], vertex: 0, display: pastel.white("O") },
}

Connectors = {
  :east => :west,
  :west => :east,
  :north => :south,
  :south => :north
}

class Tile
  attr_reader :coordinate
  attr_reader :outward
  attr_reader :inward
  attr_accessor :role
  attr_accessor :label

  def initialize(coordinate:, label:)
    @coordinate = coordinate
    @label      = label
    @outward    = LabelMeta[@label][:directions]
    @inward     = @outward.map { |c| Connectors[c] }
    @role       = nil
  end

  def meta
    case role
    when :edge
      LabelMeta[label]
    when :ground
      LabelMeta["."]
    when :inside
      LabelMeta["I"]
    when :outside
      LabelMeta["O"]
    when :start
      LabelMeta[label]
    else # everything else
      LabelMeta[label]
    end
  end

  def display
    if role == :start then
      LabelMeta['S'][:display]
    else
      meta[:display]
    end
  end

  def vertex
    @vertex ||= meta[:vertex]
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
    (role == :start) || (outward.size == 4)
  end

  def inside?
    role == :inside
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

  def rows
    @grid
  end

  def inside_tiles
    [].tap do |inside|
      @grid.each do |row|
        row.each do |tile|
          inside << tile if tile.inside?
        end
      end
    end
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
    update_start_label

    current_tile = start
    visited = []

    loop do
      current_tile.role ||= :edge
      visited << current_tile
      outward_tile = next_tile_from(tile: current_tile, visited: visited)

      # no outward tile chosen, so we must be back at the beginning
      break unless outward_tile

      current_tile = outward_tile
    end

    visited
  end

  def label
    ground.rows.each do |row|
      label_row(row)
    end
  end

  def label_row(row)
    prev_vertical = nil
    is_outside = true

    walls = %w[ | L F J 7 ]

    row.each do |tile|
      if tile.role.nil? then
        tile.role = is_outside ? :outside : :inside
        next
      end

      # all edges below here
      next if tile.label == "-"

      if prev_vertical.nil? && walls.include?(tile.label) then
        is_outside = !is_outside
        prev_vertical = tile.label
        next
      end

      if prev_vertical == "|" && walls.include?(tile.label) then
        is_outside = !is_outside
        prev_vertical = tile.label
        next
      end

      if walls.include?(prev_vertical) && tile.label == "|" then
        is_outside = !is_outside
        prev_vertical = tile.label
        next
      end

      case [prev_vertical, tile.label]
      when ["L", "J"]
        is_outside = !is_outside
      when ["L", "7"]
        # no change
      when ["F", "J"]
        # no change
      when ["F", "7"]
        is_outside = !is_outside
      when ["J", "L"]
        is_outside = !is_outside
      when ["J", "F"]
        is_outside = !is_outside
      when ["7", "L"]
        is_outside = !is_outside
      when ["7", "F"]
        is_outside = !is_outside
      else
        debugger
      end
      prev_vertical = tile.label
    end
  end

  def update_start_label
    actual_outs = start.outward.select do |out_dir|
      out_coord = start.coordinate.send(out_dir)
      out_tile = ground.fetch(out_coord)
      start.connected_to?(out_tile)
    end

    LabelMeta.each_pair do |orig_label, meta|
      if meta[:directions] == actual_outs then
        start.label = orig_label
        break
      end
    end
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
    if tile.start? then
      start = tile
      start.role = :start
    end
    ground.place(tile: tile)
  end
end

walker = Walker.new(ground: ground, start: start)
path = walker.walk
#puts ground.to_s
#puts

walker.label
puts ground.to_s
mid_length = path.length / 2 + (path.length % 2)

puts "Mid Length  : #{mid_length}"
puts "Inside tiles: #{ground.inside_tiles.count}"
