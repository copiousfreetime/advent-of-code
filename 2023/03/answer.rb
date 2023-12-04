#!/usr/bin/env ruby

require 'debug'

Coordinate = Data.define(:row, :col)
Cell = Data.define(:value, :coordinate) do
  def row
    coordinate.row
  end

  def col
    coordinate.col
  end

  def is_dot?
    false
  end

  def is_number?
    false
  end

  def is_symbol?
    false
  end

  def adjacent_coordinates
    [].tap do |adjacent|
      ((row-1)..(row+1)).each do |r|
        next if r < 0
        ((col-1)..(col+1)).each do |c|
          next if c < 0
          coord = Coordinate.new(row: r, col: c)
          next if coord == coordinate
          adjacent << coord
        end
      end
    end
  end
end

class DotCell < Cell
  def is_dot?
    true
  end
end

class NumberCell < Cell
  def is_number?
    true
  end
end

class SymbolCell < Cell
  def is_symbol?
    true
  end
end

class NumberSpan
  attr_reader :cells

  def initialize(cells: [])
    @cells = cells
  end

  def <<(cell)
    unless cells.empty? then
      if cell.row != cells.first.row
        raise ArgumentError, "Attepting to add cell #{cell} to row #{cells.first.row}"
      end
    end
    cells << cell
  end

  def number
    cells.map(&:value).join('').to_i
  end

  def adjacent_coordinates
    cell_coordinates = cells.map(&:coordinate)
    adjacent = cells.map(&:adjacent_coordinates).flatten.uniq
    (adjacent - cell_coordinates)
  end
end

# Engine schematic addressible as [row][col]
class Schematic
  attr_reader :grid
  attr_reader :number_spans

  def initialize
    @grid = []
    @number_spans = []
  end

  def add_row(row)
    grid << row
    number_spans.concat(number_spans_from(row))
  end

  def part_numbers
    number_spans.select { |span| symbol_adjacent?(span.adjacent_coordinates) }
  end

  def cell_at(coordinate)
    grid.dig(coordinate.row, coordinate.col)
  end

  def symbol_adjacent?(coordinate_list)
    coordinate_list.any?{ |coord| cell_at(coord)&.is_symbol? }
  end

  def self.parse(input)
    Schematic.new.tap do |schematic|
      input.each.with_index do |line, row|
        row_cells = []
        line.strip.each_char.with_index do |char, col|
          coordinate = Coordinate.new(row: row, col: col)
          cell_class = case char
                       when "."
                         DotCell
                       when "0".."9"
                         NumberCell
                       else
                         SymbolCell
                       end
          cell = cell_class.new(value: char, coordinate: coordinate)
          row_cells << cell
        end
        schematic.add_row(row_cells)
      end
    end
  end

  private

  def number_spans_from(cells)
    current_span = nil
    spans = []

    cells.each do |cell|
      case cell
      when NumberCell
        current_span ||= NumberSpan.new
        current_span << cell
      else
        spans << current_span unless current_span.nil?
        current_span = nil
      end
    end

    spans
  end
end


schematic = Schematic.parse(ARGF)
puts schematic.part_numbers.map(&:number).sum
