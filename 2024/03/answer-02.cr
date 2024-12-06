# Data file is the file give on the commandline

mul = /(?<mul>mul\((?<left>\d+),(?<right>\d+)\))/
doit = /(?<doit>do\(\))/
dont = /(?<dont>don't\(\))/

all = Regex.union([doit, dont, mul])

puts all.inspect

answer = 0
enabled = true

ARGF.each_line do |line|
  line = line.chomp
  pos = 0
  while (match = all.match(line, pos))
    puts match.inspect
    if match["doit"]?
      enabled = true
      puts "enabled"
    elsif match["dont"]?
      enabled = false
      puts "disabled"
    elsif match["mul"]? && enabled
      puts "mul"
      answer += (match["left"].to_i * match["right"].to_i)
    end
    pos = match.end
  end
end

puts "Answer: #{answer}"
# 111261688 too high
