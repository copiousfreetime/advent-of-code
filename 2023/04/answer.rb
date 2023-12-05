#!/usr/bin/env ruby

class Card
  attr_reader :id, :winning, :scratched

  def initialize(id:, winning: [], scratched: [])
    @id = id
    @winning = winning.map(&:to_i)
    @scratched = scratched.map(&:to_i)
  end

  def winners
    @scratched.select { |n| winning.include?(n) }
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

parser = InputParser.new(ARGF)
cards = []
winnings = []
parser.each do |card|
  cards << card
end

puts "Part 1 score: #{cards.map(&:score).sum}"

