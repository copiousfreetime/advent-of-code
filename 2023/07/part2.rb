#!/usr/bin/env ruby

require_relative './common'

# Override Hand grouped(cards)
class Hand
  def grouped(cards)
    groups = cards.group_by { |c| c.label }

    # quick test to see if there is only 1 key and it is 'J'
    return groups if groups.keys == %w[ J ]

    j = groups.delete('J')

    # if here are any jokers, then add the jokers to the group with the higest
    # count
    if j then
      counts_cards = groups.values.map { |cards| [cards.size, cards.first] }
      _size, best_card = counts_cards.sort.last
      debugger if best_card.nil?
      groups[best_card.label].concat(j)
    end
    groups
  end
end

labels = %w[J 2 3 4 5 6 7 8 9 T Q K A]

dealer = Dealer.new(deck_labels: labels)
hands = dealer.deal

# smallest first -- so hands now have effectively their rank which is their
# index + 1
sorted = hands.sort
scores = sorted.map.with_index { |hand, i| hand.bid * (i + 1) }

puts "Part 2 Total Winnings: #{scores.sum}"
puts "Expected Result      : 245461700"
