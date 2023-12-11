#!/usr/bin/env ruby

total_sq_feet   = 0
total_ft_ribbon = 0

ARGF.each do |line|
  line.strip!

  dimensions = line.split(/x/).map(&:to_i)

  areas  = dimensions.combination(2).map { |a,b| a*b }.sort
  perims = dimensions.combination(2).map { |a,b| 2*(a + b) }.sort
  bow    = dimensions.reduce(:*)

  total_sq_feet   += (areas.first + areas.sum * 2)
  total_ft_ribbon += (bow + perims.first)
end

puts "ft^2 of paper: #{total_sq_feet}"
puts "ft of ribbon : #{total_ft_ribbon}"
