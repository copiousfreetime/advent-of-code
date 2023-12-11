#!/usr/bin/env ruby
require 'bundler/inline'
require 'debug'
require 'optparse'

class Tile
  attr_accessor :row
  attr_accessor :col
  attr_accessor :id
  attr_accessor :width
  attr_accessor :height

  def initialize(row:, col:, id: nil)
    @row = row
    @col = col
    @id = id
    @width = 1
    @height = 1
  end

  def galaxy?
    !id.nil?
  end

  def space?
    !galaxy?
  end

  def distance_from(tile)
    row_delta = (row - tile.row).abs
    col_delta = (col - tile.col).abs
    (col_delta + row_delta)
  end

  def to_s
    return "#" if galaxy?
    return "." if width == 1 && height == 1
    return "o" if width > 1 && height == 1
    return "o" if width == 1 && height > 1
    return "*" if width > 1 && height > 1
    return "?"
  end
end

class Cosmos
  attr_reader :initial_row_count
  attr_reader :initial_col_count
  attr_reader :galaxies

  def initialize(row_count:, col_count:, expansion_factor: 2)
    @initial_row_count = row_count
    @initial_col_count = col_count
    @expansion_factor = expansion_factor
    @grid = Array.new(row_count) { |index| Array.new(col_count) }
    @galaxies = []
  end

  def galaxy_pairs
    galaxies.combination(2)
  end

  def distances
    galaxy_pairs.map { |a,b| a.distance_from(b) }
  end

  def row_count
    @grid.map { |r| r[0].height }.sum
  end

  def col_count
    @grid.first.map { |c| c.width }.sum
  end

  def place(row:, col:, label:)
    tile = Tile.new(row: row, col: col)
    if label == "#" then
      id = @galaxies.size + 1
      tile.id = id
      @galaxies << tile
    end
    @grid[row][col] = tile
  end

  def rows
    @grid
  end

  def to_s
    @grid.map { |row| row.join('') }.join("\n")
  end

  def expand
    @grid = expand_cols(grid: expand_rows(grid: @grid))
    update_tile_coordinates
  end

  def update_tile_coordinates
    row_offset = 0

    @grid.each do |row|
      col_offset = 0

      row.each do |tile|
        tile.row = row_offset
        tile.col = col_offset
        col_offset += tile.width
      end

      row_offset += row[0].height
    end
  end

  private

  def expand_rows(grid:, dimension: :height)
    grid.each do |row|
      if row.all? { |c| c.space? } then
        row.each { |c| c.send("#{dimension}=", @expansion_factor) }
      end
    end
    grid
  end

  def expand_cols(grid:)
    expand_rows(grid: grid.transpose, dimension: :width).transpose
  end
end

expansion_factor = 2
OptionParser.new do |opts|
  opts.banner = "Usage: answer.rb [options]"

  opts.on("-eSIZE",  "--expansion=SIZE", "Sent Expansion Factor") do |f|
    expansion_factor = f.to_i
  end
end.parse!

chars     = ARGF.readlines.map(&:strip).map(&:chars)
row_count = chars.size
col_count = chars[0].length
cosmos    = Cosmos.new(row_count: row_count, col_count: col_count, expansion_factor: expansion_factor)

chars.each.with_index do |row, row_coord|
  row.each.with_index do |label, col_coord|
    cosmos.place(row: row_coord, col: col_coord, label: label)
  end
end


puts cosmos.to_s
puts "#{cosmos.row_count} X #{cosmos.col_count}"
cosmos.expand

puts

puts cosmos.to_s
puts "#{cosmos.row_count} X #{cosmos.col_count}"

# cosmos.galaxy_pairs.each do |a,b|
#   puts "Between galaxy #{a.id} and galaxy #{b.id}: #{a.distance_from(b)}"
# end
puts cosmos.distances.sum
