#!/usr/bin/env ruby

require 'debug'

Coordinate = Data.define(:row, :col) do 
  include Comparable
  def <=>(other)
    row_result = row.<=>(other.row)
    return row_result unless row_result.zero?
    col.<=>(other.col)
  end
end

Cell = Data.define(:value, :coordinate) do
  include Comparable
  def row
    coordinate.row
  end

  def col
    coordinate.col
  end

  def <=>(other)
    coordinate_result = coordinate.<=>(other.coordinate)
    return coordinate_result unless coordinate_result.zero?
    value.<=>(other.value)
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

  def is_potential_gear?
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

class PotentialGearCell < SymbolCell
  def is_potential_gear?
    true
  end
end

class Gear
  def initialize(cell:, parts:)
    @cell = cell
    @parts = parts
  end

  def ratio
    @parts.map(&:number).reduce(:*)
  end
end

class NumberSpan
  include Comparable
  attr_reader :cells

  def initialize(cells: [])
    @cells = cells
  end

  def ==(other)
    cells.sort == other.cells.sort
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
  attr_reader :potential_gears

  def initialize
    @grid = []
    @number_spans = []
    @potential_gears = []
    @part_number_lokup = nil
  end

  def add_row(row)
    grid << row
    number_spans.concat(number_spans_from(row))
    potential_gears.concat(potential_gears_from(row))
  end

  def part_numbers
    number_spans.select { |span| symbol_adjacent?(span.adjacent_coordinates) }
  end

  def part_number_by_coordinate(coordinate)
    @part_number_lookup ||= build_part_number_lookup
    @part_number_lookup[coordinate]
  end

  def gears
    [].tap do |gear_list|
      potential_gears.each do |pg|
        adjacent_parts = pg.adjacent_coordinates.map { |c| part_number_by_coordinate(c) }.compact
        adjacent_parts.uniq!
        if adjacent_parts.size == 2 then
          gear_list << Gear.new(cell: pg, parts: adjacent_parts)
        end
      end
    end
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
                       when "*"
                         PotentialGearCell
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

  def potential_gears_from(cells)
    cells.select { |cell| cell.is_potential_gear? }
  end

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

    unless current_span.nil? then
      spans << current_span
    end

    spans
  end

  def build_part_number_lookup
    {}.tap do |lookup|
      part_numbers.each do |number|
        number.cells.each do |cell|
          lookup[cell.coordinate] = number
        end
      end
    end
  end
end


schematic = Schematic.parse(ARGF)
#part_numbers = schematic.part_numbers
#schematic.number_spans.each do |s|
#  is_part = part_numbers.include?(s) ? "*" : " "
#  #puts "#{is_part} #{s.number}"
#end

#schematic.gears.each do |g|
  #puts g
#end
puts "Part Number sum: #{schematic.part_numbers.map(&:number).sum}"
puts "Gear Ratios sum: #{schematic.gears.map(&:ratio).sum}"
