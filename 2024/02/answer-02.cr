# Data file is the file give on the commandline

count = 0

def is_safe?(levels)

  deltas = Array(Int32).new
  levels.each_cons_pair do |a, b|
    deltas << a - b
  end

  (deltas.all? { |x| x.abs >= 1 && x.abs <= 3 }) && (deltas.all? { |x| x < 0 } || deltas.all? { |x| x > 0 })
end

ARGF.each_line do |line|
  levels = line.chomp.split.map { |x| x.to_i }
  #puts "Levels: #{levels}"

  if is_safe?(levels)
    count += 1
  else
    levels.each_with_index do |x, i|
      partial = levels.dup
      partial.delete_at(i)
      #puts "Checking #{partial}"
      if is_safe?(partial)
        count += 1
        break
      end
    end
  end
end

puts "Answer: #{count}"

