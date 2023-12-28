#!/usr/bin/env ruby

def h(input)
  value = 0
  input.chars.each do |ch|
    value += ch.ord
    value *= 17
    value = value % 256
  end
  return value
end

sequences = ARGF.read.chomp.split(",")

result = sequences.map { |seq| h(seq) }.sum
puts result
