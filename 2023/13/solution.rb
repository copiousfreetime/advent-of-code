#!/usr/bin/env ruby
require 'debug'
chunks = ARGF.read.split("\n\n")

PART1 = 30705

class Field
  attr_reader :grid

  def initialize(raw:)
    @raw = raw
    @grid = @raw.split("\n").map(&:chars)
  end

  def row_count
    @grid.length
  end

  def col_count
    @grid.first.length
  end

  def score(diff: 0)
    h_index = line_of_symmetry(grid:, diff:)
    if h_index then
      return 100 * (h_index + 1)
    end

    tgrid = grid.transpose
    v_index = line_of_symmetry(grid: tgrid, diff:)
    return v_index + 1
  end

  def row_delta(a:, b:)
    delta = 0
    a.each.with_index do |e, i|
      delta += 1 if e != b[i]
    end
    return delta
  end

  def line_of_symmetry(grid:, diff:)
    (0...(grid.length-1)).each do |split_index|

      top = grid[0..split_index]
      bottom = grid[split_index+1..-1]

      compare_length = [top.length, bottom.length].min

      top = top.reverse[0, compare_length]
      bottom = bottom[0, compare_length]

      delta = 0
      top.each.with_index do |t, i|
        delta += row_delta(a: t, b: bottom[i])
      end
      return split_index if delta == diff
    end
    return nil
  end
end

[ 0 , 1 ].each do |diff|
  total = 0
  chunks.each do |c|
    field = Field.new(raw: c)
    score = field.score(diff:)
    total += score
  end
  puts "Diff: #{diff} Total: #{total}"
end
