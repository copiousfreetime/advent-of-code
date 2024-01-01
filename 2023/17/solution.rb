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
  attr_accessor :heat_loss
  attr_accessor :before_heat_loss
  attr_accessor :from_coordinate

  def initialize(row:, col:, heat_loss:)
    @coordinate = Coordinate.new(row:, col:)
    @heat_loss = heat_loss.to_i
    @visited = false
    @before_heat_loss = Float::INFINITY
    @from_coordinate = nil
  end

  def total_heat_loss
    @before_heat_loss + @heat_loss
  end

  def visit!
    @visited = true
  end

  def visited?
    @visited
  end

  def glyph
    heat_loss.to_s
  end

  def adjust_before_heat_loss(from_coordinate:, heat_loss:)
    return unless heat_loss <= before_heat_loss
    @before_heat_loss = heat_loss
    @from_coordinate = from_coordinate
  end

  def display(in_path: visited?)
    if in_path then
      COLOR.yellow(glyph)
      # case from_coordinate
      # when coordinate.right
      #   COLOR.yellow("<")

      # when coordinate.left
      #   COLOR.yellow(">")

      # when coordinate.down
      #   COLOR.yellow("^")

      # when coordinate.up
      #   COLOR.yellow("v")
      # when nil
      #   COLOR.yellow("#")
      # else
      #   debugger
      #   raise :boom
      # end
    else
      if visited? then
        COLOR.green(glyph)
      elsif @before_heat_loss < Float::INFINITY
        COLOR.blue(glyph)
      else
        COLOR.red(glyph)
      end
    end
  end

  def to_s
    glyph
  end

  def neighbor_coordinates
    [
      coordinate.up,
      coordinate.down,
      coordinate.left,
      coordinate.right,
    ]
  end
end

class Grid
  attr_reader :col_count
  attr_reader :row_count

  include Enumerable

  def initialize(lines)
    @lines = lines.map(&:strip)
    @tiles = generate_tiles(@lines)
    @row_count = @tiles.size
    @col_count = @tiles.first.size
  end

  def [](row)
    @tiles[row]
  end

  def fetch(coord)
    raise KeyError, "Out of bounds #{coord}" unless in_bounds?(coord)
    @tiles[coord.row][coord.col]
  end

  def first_tile
    @tiles[0][0]
  end

  def last_tile
    @tiles[-1][-1]
  end

  def each(&block)
    @tails.each do |row|
      row.each do |tile|
        yield tile
      end
    end
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

  def path_to(last: last_tile)
    path = []
    prev = nil
    current = last

    loop do
      path.unshift(current.coordinate)
      next_coord = current.from_coordinate
      break if next_coord.nil?
      current = fetch(next_coord)
    end
    return path
  end

  def display_path(last: @grid.last_tile)
    path = path_to(last:)
    @tiles.map do |row|
      row.map do |tile|
        tile.display(in_path: path.include?(tile.coordinate))
      end.join('')
    end.join("\n")
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
      row.chars.each.with_index do |heat_loss, col_coord|
        if row_coord.zero? && col_coord.zero? then
          heat_loss = 0
        end

        tile = Tile.new(row: row_coord, col: col_coord, heat_loss:)
        t[row_coord][col_coord] = tile
      end
    end

    t
  end
end

CURSOR = TTY::Cursor

class Dijkstra
  def initialize(grid:, max_same: 4)
    @grid = grid
    @max_same = max_same
  end

  def contains_straight?(path:)
    path.each_cons(@max_same + 1) do |sub|
      return true if sub.map{ |p| p.row}.uniq.size == 1
      return true if sub.map{ |p| p.col}.uniq.size == 1
    end
    return false
  end

  def too_straight?(path:)
    return false if path.length <= (@max_same + 1)
    tail = path.last(@max_same + 1)

    return true if tail.map{|p| p.row}.uniq.size == 1
    return true if tail.map{|p| p.col}.uniq.size == 1
    return false
  end

  def traverse(start: @grid.first_tile.coordinate, stop: @grid.last_tile.coordinate)
    current_tile = @grid.fetch(start)
    current_tile.before_heat_loss = 0

    unvisited = []
    unvisited.push(current_tile)

    while current_tile = unvisited.shift do

      #debugger
      current_path = @grid.path_to(last: current_tile)
      current_tile.neighbor_coordinates.each do |c|
        next unless @grid.in_bounds?(c)

        neighbor_tile = @grid.fetch(c)
        #debugger
        next if neighbor_tile.visited?
        next if too_straight?(path: current_path + [c])

        neighbor_tile.adjust_before_heat_loss(from_coordinate: current_tile.coordinate, heat_loss: current_tile.total_heat_loss)
        unvisited.push(neighbor_tile) unless unvisited.include?(neighbor_tile)
      end
      current_tile.visit!
      unvisited.sort_by! { |t| t.before_heat_loss }

      puts @grid.display_path(last: current_tile)
      puts
    end
  end
end

lines = ARGF.readlines
grid = Grid.new(lines)
walker = Dijkstra.new(grid: grid)
walker.traverse
puts grid.display_path(last: grid.last_tile)
debugger
puts grid.last_tile.total_heat_loss


