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

boxes = Array.new(256) { |a| a = Hash.new }

sequences = ARGF.read.chomp.split(",")

sequences.each do |seq|
  #puts "After \"#{seq}\""
  if seq =~ /=/ then
    label, focal = seq.split("=")

    box_slot = h(label)
    box = boxes[box_slot]
    box[label] = focal.to_i
  elsif seq =~ /-/ then
    label, _ = seq.split("-")
    box_slot = h(label)
    box = boxes[box_slot]
    box.delete(label)
  else
    raise "boom"
  end
end

total = 0
boxes.each.with_index do |b, i|
  next if b.empty?
  b_score = i + 1
  b.to_a.each.with_index do |(label, focal), i2|
    lens_score = b_score * (i2 + 1) * focal
    puts "label: #{label} #{i+1} * #{(i2+1)} * #{focal} => #{lens_score}"
    total += lens_score
  end
end

puts total

