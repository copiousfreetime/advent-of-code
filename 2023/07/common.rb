
module ValueComparable
  include Comparable
  def <=>(other)
    value.<=>(other.value)
  end
end

Card = Data.define(:label, :value) do
  include ValueComparable
end

HandType = Data.define(:name, :value) do
  include ValueComparable
end

FiveOfAKind  = HandType.new(name: "Five of a kind",  value: 6)
FourOfAKind  = HandType.new(name: "Four of a kind",  value: 5)
FullHouse    = HandType.new(name: "Full House",      value: 4)
ThreeOfAKind = HandType.new(name: "Three of a kind", value: 3)
TwoPair      = HandType.new(name: "Two Pair",        value: 2)
OnePair      = HandType.new(name: "One Pair",        value: 1)
HighCard     = HandType.new(name: "High Card",       value: 0)

class TypeDetector
  def self.call(hand)
    case hand
    in { distinct_cards: 5 }
      HighCard
    in { distinct_cards: 4 }
      OnePair
    in { distinct_cards: 3, most_cards: 2 }
      TwoPair
    in { distinct_cards: 3, most_cards: 3 }
      ThreeOfAKind
    in { distinct_cards: 2, most_cards: 3 }
      FullHouse
    in { distinct_cards: 2, most_cards: 4 }
      FourOfAKind
    in { distinct_cards: 1 }
      FiveOfAKind
    else
      raise ArgumentError, "Unable to detect hand: #{hand}"
    end
  end
end

class Hand
  attr_reader :original_cards
  attr_reader :cards
  attr_reader :bid
  attr_reader :distinct_cards
  attr_reader :most_cards
  attr_reader :type

  include Comparable

  def initialize(cards:, bid:)
    @original_cards = cards
    @cards = cards.sort.reverse
    @bid = bid.to_i
    @grouped = grouped(cards)
    @distinct_cards = @grouped.size
    @most_cards = @grouped.values.map(&:size).max
    @type = TypeDetector.(self)
  end

  def grouped(cards)
    cards.group_by { |c| c.label }
  end

  def to_s
    "Hand(cards: #{cards.map(&:label)}, type: #{type}, bid: #{bid})"
  end

  def deconstruct_keys(keys)
    {
      distinct_cards: distinct_cards,
      most_cards: most_cards
    }
  end

  def <=>(other)
    type_compare = type.<=>(other.type)
    return type_compare unless type_compare.zero?

    original_cards.zip(other.original_cards).each do |my_card, their_card|
      return my_card.<=>(their_card) unless my_card == their_card
    end

    # same hand
    return 0
  end
end

class Dealer
  def initialize(input: ARGF, deck_labels:)
    @input = input
    @deck = generate_deck(deck_labels)
  end

  def deal
    @input.readlines.map do |deal|
      labels, bid = deal.strip.split(/\s+/)
      cards = labels.chars.map { |c| @deck[c] }
      Hand.new(cards: cards, bid: bid.to_i)
    end
  end

  private

  def generate_deck(labels)
    {}.tap do |d|
      labels.each.with_index do |l, i|
        d[l] = Card.new(label: l, value: i)
      end
    end
  end
end


