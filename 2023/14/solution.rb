#!/usr/bin/env ruby

grid = ARGF.readlines.map(&:strip).map(&:chars)

def score(grid:)
  score = 0
  grid.reverse.each.with_index do |row, i|
    score += (row.count('O') * (i+1))
  end
  return score
end

def shift_north(grid:)
  (1...grid.length).each do |current_row_index|
    (0...grid.first.length).each do |current_col_index|

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

def shift_west(grid:)
  (1...grid.first.length).each do |current_col_index|
    (0...grid.length).each do |current_row_index|

      current_char = grid[current_row_index][current_col_index]
      next unless current_char == 'O'

      grid[current_row_index][current_col_index] = "."

      dest_col_index = current_col_index

      (current_col_index - 1).downto(0) do |west_index|
        break if grid[current_row_index][west_index] == '#'
        break if grid[current_row_index][west_index] == 'O'
        dest_col_index = west_index
      end

      grid[current_row_index][dest_col_index] = "O"
    end
  end
  grid
end

def shift_south(grid:)
  (grid.length-2).downto(0) do |current_row_index|
    (0...grid.first.length).each do |current_col_index|

      current_char = grid[current_row_index][current_col_index]
      next unless current_char == 'O'

      grid[current_row_index][current_col_index] = "."
      dest_row_index = current_row_index

      (current_row_index + 1).upto(grid.length-1) do |south_index|
        break if grid[south_index][current_col_index] == '#'
        break if grid[south_index][current_col_index] == 'O'
        dest_row_index = south_index
      end

      grid[dest_row_index][current_col_index] = "O"
    end
  end
  grid
end

def shift_east(grid:)
  (grid.first.length-2).downto(0) do |current_col_index|
    (0...grid.length).each do |current_row_index|

      current_char = grid[current_row_index][current_col_index]
      next unless current_char == 'O'

      grid[current_row_index][current_col_index] = "."

      dest_col_index = current_col_index

      (current_col_index + 1).upto(grid.first.length-1) do |east_index|
        break if grid[current_row_index][east_index] == '#'
        break if grid[current_row_index][east_index] == 'O'
        dest_col_index = east_index
      end

      grid[current_row_index][dest_col_index] = "O"
    end
  end
  grid
end

def rotate(grid:)
  out = Array.new(grid.length) { |a| a = Array.new(grid.first.length) }
  (0...grid.length).each do |in_row_index|
    (0...grid.first.length).each do |in_col_index|
      out_row_index = in_col_index
      out_col_index = grid.first.length - 1 - in_row_index
      out[out_row_index][out_col_index] = grid[in_row_index][in_col_index]
    end
  end
  out
end

def grid_id(grid:)
  grid.map do |r|
    r.join('')
  end.join("\n")
end

def dump_grid(grid:)
  grid.each do |r|
    puts r.join('')
  end
end

def cycle(grid:)
  4.times do
    grid = shift_north(grid:)
    grid = rotate(grid:)
  end
  grid
end

prev_score = 0
current_score = nil
dump_grid(grid:)
puts "=" * 42
count = 1_000_000_000
i = 0

by_grid = {}

while i < count do
  i += 1
  grid = cycle(grid:)
  grid_id = grid_id(grid:)

  if by_grid.include?(grid_id) then
    cycle_length = i - by_grid[grid_id]
    jump_by = (count - i) / cycle_length
    i += (jump_by*cycle_length)
  end
  by_grid[grid_id] = i
  puts "iteration #{i} score #{score(grid:)}"
end

puts score(grid:)

