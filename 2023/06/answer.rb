#!/usr/bin/env ruby

# leaving as strings because part 1 and part 2 handle the values differently
#
race_times = ARGF.readline.split(":").last.strip.split(/\s+/)
record_distances = ARGF.readline.split(":").last.strip.split(/\s+/)

Race = Data.define(:race_time, :record_distance)

races = race_times.map.with_index do |t, i|
  Race.new(race_time: t, record_distance: record_distances[i])
end

# we only need the count of winning combos, not the combos themselves
#
def winning_combos_count(race)
  race_time       = race.race_time.to_i
  record_distance = race.record_distance.to_i
  count           = 0

  (1...race_time).each do |hold_time|
    speed          = hold_time
    movement_time  = race_time - hold_time
    distance       = speed * movement_time
    count         += 1 if distance > record_distance
  end

  count
end

def part_1(races)
  expected = 140220
  puts "Expected : #{expected}"

  counts = races.map { |race| winning_combos_count(race) }

  puts "Part 1   : #{counts.reduce(:*)}"
end

def part_2(races)
  expected = 39570185
  puts "Expected : #{expected}"

  race_time       = races.map(&:race_time).join("").to_i
  record_distance = races.map(&:record_distance).join("").to_i
  big_race        = Race.new(race_time: race_time, record_distance: record_distance)
  count           = winning_combos_count(big_race)

  puts "Part 2   : #{count}"
end

part_1(races)
part_2(races)
