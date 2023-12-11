#!/usr/bin/env ruby
require 'bundler/inline'
require 'debug'

gemfile do
  source 'https://rubygems.org'
  gem 'pastel'
  gem 'tty-cursor'
end

class Cosmos
  attr_reader :initial_row_count
  attr_reader :initial_col_count

  def initialize(row_count:, col_count:)
    @initial_row_count = row_count
    @initial_col_count = col_count
    @grid = Array.new(row_count) { |index| Array.new(col_count) }
  end

  def fetch(row:, col:)
    @grid[row][col]
  end

  def place(row:, col:, value:)
    @grid[row][col] = value
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
  end

  private

  def expand_rows(grid)
    empty_indexes = []
    grid.each.with_index do |row, index|
      empty_indexes << index if row.all? { |c| c == "." }
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
    cosmos.place(row: row_coord, col: col_coord, value: label)
  end
end


puts cosmos.to_s
cosmos.expand

puts

puts cosmos.to_s

