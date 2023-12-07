#!/usr/bin/env ruby

require_relative './common'

labels = %w[2 3 4 5 6 7 8 9 T J Q K A]
dealer = Dealer.new(deck_labels: labels)
hands  = dealer.deal

# smallest first -- so hands now have effectively their rank which is their
# index + 1
sorted = hands.sort
scores = sorted.map.with_index { |hand, i| hand.bid * (i + 1) }

puts "Part 1 Total Winnings: #{scores.sum}"
puts "Expected Result      : 247823654"

