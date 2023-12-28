#!/usr/bin/env ruby

grid = ARGF.readlines.map(&:chars)

def score(grid:)
  score = 0
  grid.reverse.each.with_index do |row, i|
    score += (row.count('O') * (i+1))
  end
  return score
end

def shift_north(grid:)
  (1...grid.length).each do |current_row_index|
    current_row = grid[current_row_index]

    (0...current_row.length).each do |current_col_index|
      current_char = grid[current_row_index][current_col_index]
      next unless current_char == 'O'

      grid[current_row_index][current_col_index] = "."
      dest_row_index = current_row_index

      (current_row_index - 1).downto(0) do |north_index|
        break if grid[north_index][current_col_index] == '#'
        break if grid[north_index][current_col_index] == 'O'
        dest_row_index = north_index
      end

      grid[dest_row_index][current_col_index] = "O"
    end
  end
  grid
end

grid = shift_north(grid:)

puts score(grid:)

