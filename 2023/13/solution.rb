#!/usr/bin/env ruby
require 'debug'
chunks = ARGF.read.split("\n\n")

class RowCol
  attr_reader :value
  attr_reader :index

  def initialize(value:, index:)
    @value = value
    @index = index
  end

  def ==(other)
    self.value == other.value
  end

  def length
    @value.length
  end

  def to_a
    @value.chars
  end
end

class Field
  attr_reader :rows

  def initialize(raw:)
    @raw = raw
    @rows = @raw.split("\n").map.with_index { |r,i| RowCol.new(value: r, index: i) }
  end

  def row_count
    @rows.size
  end

  def col_count
    @row.first.length
  end

  def convert_rows_to_cols
    matrix = rows.map(&:to_a).transpose
    matrix.map.with_index do |r, i|
      RowCol.new(value: r.join(""), index: i)
    end
  end

  def score
    if top_score = reflective_score(rows: @rows) then
      return top_score * 100
    elsif bottom_score = reflective_score(rows: @rows.reverse)
      return (rows.length - bottom_score) * 100
    else
      cols = convert_rows_to_cols
      if left_score = reflective_score(rows: cols)
        return left_score
      elsif right_score = reflective_score(rows: cols.reverse)
        return (cols.length - right_score)
      else
        debugger
        raise "boom!"
      end
    end
  end

  def fold_check(rows:, left_index:)
    right_index = left_index + 1
    fold_length = [ (left_index + 1), (rows.length - right_index)].min
    good = false
    fold_length.times do |l|
      return false unless (rows[left_index-l] == rows[right_index+l])
    end
    return true
  end

  def reflective_score(rows: )
    score = nil

    rows.each_cons(2) do |a,b|
      if (a == b) && fold_check(rows:, left_index: a.index) then
        score = b.index
        break
      end
    end

    return score
  end
end

total = 0
chunks.each do |c|
  field = Field.new(raw: c)
  score = field.score
  puts score
  total += score
end
puts total
