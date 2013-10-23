require 'csv'
require 'pp'

puts "---"
CSV.foreach(ARGV[0]) do |row|
  word = row.first
  word.gsub!(/\s[-–]\s/, " (blank) ")
  word.gsub!(/\s+/, " ")
  word.gsub!(/\s\./, ".")
  word.strip!

  next if word.scan("(blank)").count > 1
  next if word.match("\([^\)]*Pick.*\)")

  puts "- #{word}"
end
