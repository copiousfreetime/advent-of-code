# Data file is the file give on the commandline

count = 0

ARGF.each_line do |line|
  levels = line.chomp.split.map { |x| x.to_i }
  deltas = Array(Int32).new

  levels.each_cons_pair do |a, b|
    deltas << a - b
  end

  if (deltas.all? { |x| x.abs >= 1 && x.abs <= 3 }) &&
      (deltas.all? { |x| x < 0 } || deltas.all? { |x| x > 0 })
    count += 1
  end
end

puts "Answer: #{count}"

