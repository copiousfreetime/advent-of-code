# Data file is the file give on the commandline

regex = /(?:mul\((?<left>\d+),(?<right>\d+)\))/

answer = 0

ARGF.each_line do |line|
  line = line.chomp
  pos = 0
  while (match = regex.match(line, pos))
    answer += (match["left"].to_i * match["right"].to_i)
    pos = match.end
  end
end

puts "Answer: #{answer}"

