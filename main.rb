require 'csv'
require 'optparse'
# CITY,YEAR,MONTH
puts "#{ARGV.length}"


if ARGV.length==3
  str = "#{ARGV[0].capitalize}_weather\\#{ARGV[0].capitalize}_weather_#{ARGV[1]}_#{ARGV[2].capitalize}.txt"
end
puts str
# country str= "#{}_weather\Dubai_weather_2004_Aug.txt"
begin
csv_data = CSV.read(str, headers: true)
rescue
  puts "Invlaid Input"
  return
end

# def average highest_tempertaure()


csv_data.each do |row|
  
end