# Algorithm is going to be
# 1. load the data into a matrix
# 2. for each positions in the matrix, check if the value is an "A"
# 3. if it is an "A", check all surrouding values for the list of values at the
# possible positions

TL = [ [-1, 1, 'M'], [ 1,-1, 'S'] ]
TR = [ [ 1, 1, 'M'], [-1,-1, 'S'] ]
BR = [ [ 1,-1, 'M'], [-1, 1, 'S'] ]
BL = [ [-1,-1, 'M'], [ 1, 1, 'S'] ]

patterns = [ TL, TR, BR, BL ].combinations(2)

matrix = Array(Array(Char)).new

ARGF.each_line do |line|
   matrix << line.chomp.chars
   #puts line.chomp.chars.join(" ")
end

#puts matrix

answer = 0

matrix.each_with_index do |row, row_index|
   row.each_with_index do |char, col_index|
      next unless char == 'A'

      patterns.each do |pattern_combo|

         # pattern combo is the 2 pairs that make an X
         found = pattern_combo.all? do |mas|
            mas.all? do |parts|

               col_offset = parts[0].as(Int32)
               row_offset = parts[1].as(Int32)
               expected_char = parts[2].as(Char)

               col_check = col_index + col_offset
               row_check = row_index + row_offset

               (col_check >= 0) &&
                  (col_check < row.size) &&
                  (row_check >= 0) &&
                  (row_check < matrix.size) && 
                  matrix[row_check][col_check] == expected_char
            end
         end
         if found
            puts "Found X-MAS at (#{char},(#{col_index},#{row_index}))"
            answer += 1
            break
         end
      end
   end
end
puts "Answer: #{answer}"
