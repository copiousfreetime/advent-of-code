# Algorithm is going to be
# 1. load the data into a matrix
# 2. for each positions in the matrix, check if the value is an "X"
# 3. if it is an "X", check all surrouding values for the list of values at the
# possible positions

final_char = 'S'

patterns = [
   [ [ 0, 1, 'M'], [ 0, 2, 'A'], [ 0, 3, 'S'] ],
   [ [ 1, 1, 'M'], [ 2, 2, 'A'], [ 3, 3, 'S'] ],
   [ [ 1, 0, 'M'], [ 2, 0, 'A'], [ 3, 0, 'S'] ],
   [ [ 1,-1, 'M'], [ 2,-2, 'A'], [ 3,-3, 'S'] ],
   [ [ 0,-1, 'M'], [ 0,-2, 'A'], [ 0,-3, 'S'] ],
   [ [-1,-1, 'M'], [-2,-2, 'A'], [-3,-3, 'S'] ],
   [ [-1, 0, 'M'], [-2, 0, 'A'], [-3, 0, 'S'] ],
   [ [-1, 1, 'M'], [-2, 2, 'A'], [-3, 3, 'S'] ]
]

matrix = Array(Array(Char)).new

ARGF.each_line do |line|
   matrix << line.chomp.chars
   #puts line.chomp.chars.join(" ")
end

#puts matrix

answer = 0

matrix.each_with_index do |row, row_index|
   row.each_with_index do |char, col_index|
      next unless char == 'X'

      patterns.each do |pattern_direction|
         found = false

         #puts "Testing at #{col_index},#{row_index} for #{pattern_direction}"
         pattern_direction.each_with_index do |parts, i|
            col_offset = parts[0].as(Int32)
            row_offset = parts[1].as(Int32)
            expected_char = parts[2].as(Char)

            col_check = col_index + col_offset
            break if col_check < 0
            break if col_check >= row.size

            row_check = row_index + row_offset
            break if row_check < 0
            break if row_check >= matrix.size

            break unless matrix[row_check][col_check] == expected_char
            #puts "found #{expected_char} at (#{col_check},#{row_check})"

            found = true if i == 2
         end
         if found
            #puts "Found XMAS at (#{char},(#{col_index},#{row_index})) in direction #{pattern_direction[0]}"
            answer += 1
         end
      end
   end
end
puts "Answer: #{answer}"
