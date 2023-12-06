#!/usr/bin/env ruby

race_times = ARGF.readline.split(":")[1].strip.split(/\s+/).map(&:to_i)
record_distances = ARGF.readline.split(":")[1].strip.split(/\s+/).map(&:to_i)

Race = Data.define(:race_time, :record_distance)

races = race_times.map.with_index do |t, i|
  Race.new(race_time: t, record_distance: record_distances[i])
end

def winning_combos(race)
  (1...race.race_time).map do |hold_time|
    speed = hold_time
    movement_time = race.race_time - hold_time
    distance = speed * movement_time
    if distance > race.record_distance then
      distance
    end
  end.compact
end

counts = races.map { |race| winning_combos(race).count }
puts "Part 1: #{counts.reduce(:*)}" # 140220

