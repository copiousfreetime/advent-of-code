#!/usr/bin/env ruby

class Card
  attr_reader :id, :winning, :scratched

  def initialize(id:, winning: [], scratched: [])
    @id = id.to_i
    @winning = winning.map(&:to_i)
    @scratched = scratched.map(&:to_i)
  end

  def winner?
    winners.count.nonzero?
  end

  def winners
    @scratched.select { |n| winning.include?(n) }
  end

  def win_copies_of
    [].tap do |add|
      winners.count.times do |i|
        add << i + 1 + id
      end
    end
  end

  def score
    power = winners.count
    return 0 if power.zero?
    2 ** (power-1)
  end

  def to_s
    "id: #{id} winning: #{winning.join(' ')} scratched: #{scratched.join(' ')}"
  end
end

class InputParser
  def initialize(input)
    @input = input
  end

  def each
    @input.each do |line|
      yield parse_line_to_card(line)
    end
  end

  def parse_line_to_card(line)
    raw_card, raw_play = line.split(":").map(&:strip)
    _, id = raw_card.split(/\s+/)

    raw_winning, raw_scratched = raw_play.split("|").map(&:strip)
    winning = raw_winning.split(/\s+/).map(&:strip)
    scratched = raw_scratched.split(/\s+/).map(&:strip)

    Card.new(id: id, winning: winning, scratched: scratched)
  end
end

class Part1Scorer
  attr_reader :cards
  def initialize
    @cards = []
  end

  def <<(card)
    @cards << card
  end

  def final_score
    cards.map(&:score).sum
  end
end

class Part2Scorer
  attr_reader :cards
  def initialize
    @cards = {}
  end

  def <<(card)
    @cards[card.id] = card
  end

  def valid_card_id?(id)
    @cards.has_key?(id)
  end

  def original_winners
    @cards.values.select { |c| c.winner? }
  end

  # score the cards from highest number to lowest since
  # no card will have a score from a id that is less than it.
  # Cache the scores so we can just sum them up at the end
  def final_score
    input = @cards.values.sort_by { |c| c.id }.reverse
    score = 0
    card_cache_score = {}
    while card = input.shift do
      card_score = 1
      card.win_copies_of.each do |id|
        next unless valid_card_id?(id)
        card_score += card_cache_score[id]
      end
      card_cache_score[card.id] = card_score
    end
    card_cache_score.values.sum
  end
end

parser = InputParser.new(ARGF)
part_1 = Part1Scorer.new
part_2 = Part2Scorer.new

parser.each do |card|
  part_1 << card
  part_2 << card
end

puts "Part 1 score: #{part_1.final_score}"
puts "Part 2 score: #{part_2.final_score}"

