# Data file is the file give on the commandline

# column 1 is the keys, column 2 we need to count the number of times it appears

left = Array(Int32).new
right = Hash(Int32, Int32).new { |h, k| h[k] = 0 }

ARGF.each_line do |line|
  l, r = line.chomp.split.map { |x| x.to_i }
  left << l
  right[r] += 1
end

similarity = 0

left.each do |l|
  similarity += (l * right[l])
end

puts "Similarity: #{similarity}"

