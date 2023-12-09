#!/usr/bin/env ruby

floor = 0
position = nil

ARGF.each_char.with_index do |char, index|
  floor += 1 if char == "("
  floor -= 1 if char == ")"

  if position.nil? && (floor < 0) then
    position = index + 1
  end
end

puts "End Floor         : #{floor}"
puts "Basement Position : #{position}"
