#!/usr/bin/env ruby

race_times = ARGF.readline.split(":")[1].strip.split(/\s+/)
record_distances = ARGF.readline.split(":")[1].strip.split(/\s+/)

Race = Data.define(:race_time, :record_distance)

races = race_times.map.with_index do |t, i|
  Race.new(race_time: t, record_distance: record_distances[i])
end

def winning_combos(race)
  race_time = race.race_time.to_i
  record_distance = race.record_distance.to_i

  (1...race_time).map do |hold_time|
    speed = hold_time
    movement_time = race_time - hold_time
    distance = speed * movement_time
    if distance > record_distance.to_i then
      distance
    end
  end.compact
end

def part_1(races)
  counts = races.map { |race| winning_combos(race).count }
  puts "Part 1: #{counts.reduce(:*)}" # 140220
end

def part_2(races)
  race_time = races.map(&:race_time).join("").to_i
  record_distance = races.map(&:record_distance).join("").to_i
  big_race = Race.new(race_time: race_time, record_distance: record_distance)
  combos = winning_combos(big_race)
  puts "Part 2: #{combos.count}"
end

part_1(races)
part_2(races)
