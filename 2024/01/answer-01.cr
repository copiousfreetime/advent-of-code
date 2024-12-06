# Data file is the file give on the commandline

left = Array(Int32).new
right = Array(Int32).new

ARGF.each_line do |line|
  l, r = line.chomp.split.map { |x| x.to_i }
  left << l
  right << r
end

left.sort!
right.sort!

sum = 0

left.each_with_index do |l, i|
  sum += (l - right[i]).abs
end

puts "Sum: #{sum}"

