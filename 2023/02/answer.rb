#!/usr/bin/env ruby
require 'debug'

Reveal = Data.define(:red, :green, :blue) do
  def +(other)
    Reveal.new(
      red: red + other.red,
      green: green + other.green,
      blue: blue + other.blue
    )
  end

  def contains?(other)
    members.all? { |color| self.send(color) >= other.send(color) }
  end

  def any_zero?
    members.any? { |color| self.send(color).zero? }
  end

  def power
    raise "Oops -- got a zero" if any_zero?
    red * green * blue
  end
end

BLANK_REVEAL = Reveal.new(red: 0, green: 0, blue: 0)

Game = Data.define(:id, :reveals) do
  def playable_with?(bag)
    reveals.all? { |reveal| bag.contains?(reveal) }
  end

  def minimum_bag
    Reveal.new(
      red: reveals.map(&:red).max,
      green: reveals.map(&:green).max,
      blue: reveals.map(&:blue).max
    )
  end

  def power
    minimum_bag.power
  end
end

class InputParser
  def initialize(input)
    @input = input
  end

  def each
    @input.each do |line|
      yield parse_line_to_game(line)
    end
  end

  private

  def parse_line_to_game(line)
    raw_game, raw_reveals = line.split(':')
    _, id = raw_game.split(/\s+/)

    reveals = parse_reveals(raw_reveals)
    game = Game.new(id: id.to_i, reveals: reveals)
  end

  def parse_reveals(raw_reveals)
    [].tap do |reveals|
      raw_reveals.split(";").each do |raw_reveal|
        parts = raw_reveal.split(",")
        reveal_args = { red: 0, green: 0, blue: 0 }
        parts.each do |part|
          count, color = part.strip.split(/\s+/)
          reveal_args[color.to_sym] = count.to_i
        end
        reveals << Reveal.new(**reveal_args)
      end
    end
  end
end

bag = Reveal.new(red: 12, green: 13, blue: 14)
games_in_bag = []
powers_in_bag = []
parser = InputParser.new(ARGF)
parser.each do |game|
  if game.playable_with?(bag) then
    games_in_bag << game.id
  end
  powers_in_bag << game.power
end

puts "Sum: #{games_in_bag.sum}"
puts "Power: #{powers_in_bag.sum}"
