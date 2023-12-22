#!/usr/bin/env ruby

require 'debug'

total = 0

ARGF.each_line do |line|
  spring_raw, checks_raw = line.strip.split(/\s+/, 2)
  encoded = spring_raw.tr('.#','01')

  questions       = encoded.count('?')
  spring_template = encoded.gsub('?', '%d')
  groups          = checks_raw.split(/,/)
                               .map {  |n| "1{#{n}}" }
                               .join("0+")
  checks_regex    = Regexp.new("^0*#{groups}0*$")

  start = ("0"*questions).to_i(2)
  finish = ("1"*questions).to_i(2)

  puts "start: #{start} -> #{finish} : #{checks_raw} -> #{checks_regex}"
  (start..finish).each do |n|
    values = ("%0.#{questions}b" % n).chars
    spring = spring_template % values
    #pu7260ts spring
    if spring =~ checks_regex then
      decoded = spring.tr('01','.#')
      total += 1
      #puts "#{spring} / #{decoded} ~= #{checks_raw} / #{checks_regex}"
      #puts "Q: #{questions} T: #{spring_template} R: #{checks_regex.source} O: #{options}"
    end
  end
end
puts total
