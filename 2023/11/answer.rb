#!/usr/bin/env ruby
require 'bundler/inline'
require 'debug'

gemfile do
  source 'https://rubygems.org'
  gem 'pastel'
  gem 'tty-cursor'
end

class Tile
  attr_accessor :row
  attr_accessor :col
  attr_accessor :id

  def initialize(row:, col:, id: nil)
    @row = row
    @col = col
    @id = id
  end

  def galaxy?
    !id.nil?
  end

  def space?
    !galaxy?
  end

  def to_s
    galaxy? ? "#" : "."
  end
end

class Cosmos
  attr_reader :initial_row_count
  attr_reader :initial_col_count
  attr_reader :galaxies

  def initialize(row_count:, col_count:)
    @initial_row_count = row_count
    @initial_col_count = col_count
    @grid = Array.new(row_count) { |index| Array.new(col_count) }
    @galaxies = []
  end

  def row_count
    @grid.size
  end

  def col_count
    @grid.first.size
  end

  def fetch(row:, col:)
    @grid[row][col]
  end

  def place(row:, col:, label:)
    tile = Tile.new(row: row, col: col)
    if label == "#" then
      id = @galaxies.size
      tile.id = id
      @galaxies << tile
    end
    @grid[row][col] = tile
  end

  def [](row_coord)
    @grid[row_coord]
  end

  def rows
    @grid
  end

  def to_s
    @grid.map { |row| row.join('') }.join("\n")
  end

  def expand
    @grid = expand_cols(expand_rows(@grid))
    update_tile_coordinates
  end

  def update_tile_coordinates
    @grid.each.with_index do |row, row_coord|
      row.each.with_index do |tile, col_coord|
        tile.row = row_coord
        tile.col = col_coord
      end
    end
  end

  private

  def expand_rows(grid)
    empty_indexes = []
    grid.each.with_index do |row, index|
      if row.all? { |c| c.space? } then
        # because adding a new index then bumps the index for the next insertion
        empty_indexes << (index + empty_indexes.size)
      end
    end
    empty_indexes.each { |i| grid.insert(i, grid[i].dup) }
    grid
  end

  def expand_cols(grid)
    expand_rows(grid.transpose).transpose
  end
end

chars     = ARGF.readlines.map(&:strip).map(&:chars)
row_count = chars.size
col_count = chars[0].length
cosmos    = Cosmos.new(row_count: row_count, col_count: col_count)

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

puts cosmos.galaxies.map(&:inspect)
