require 'optparse'
require 'csv'
require 'colorize'

options = {}
OptionParser.new do |opts|
  opts.on("-e YEAR,CITY", "--exact YEAR,CITY",Array, "Get weather data for a specific year and city (required)") do |year_city|
    if year_city.length <2
      puts "Both year and city are required for the -e option."
      exit
    end
    
    # puts year_city
    options[:exact] = year_city
  end

  opts.on("-d", "--double YEAR/MONTH,CITY", "Get highest and lowest weather in one row") do |year_month_city|
    if year_month_city.split('/').length>1 && year_month_city.split('/')[1].split(',')[1]
      year = year_month_city.split('/')[0]
      month = year_month_city.split('/')[1].split(',')[0]
      city = year_month_city.split('/')[1].split(',')[1]
      options[:high_low]=[year,month,city]
    else
      puts "Year Month and City are required with -d flag"
    end
  end

  opts.on("-a", "--average YEAR/MONTH,CITY", "Get average weather data for a year/month and city") do |year_month_city|
    # options[:average] = year_month_city.split(",")
    if year_month_city.split('/').length>1 && year_month_city.split('/')[1].split(',')[1]
      year = year_month_city.split('/')[0]
      month = year_month_city.split('/')[1].split(',')[0]
      city = year_month_city.split('/')[1].split(',')[1]
      options[:average]=[year,month,city]
    else
      puts "Year Month and City are required with -a flag"
    end
  end

  opts.on("-c", "--compare YEAR/MONTH,CITY", "Compare weather data for a year/month and city") do |year_month_city|
    if year_month_city.split('/').length>1 && year_month_city.split('/')[1].split(',')[1]
      year = year_month_city.split('/')[0]
      month = year_month_city.split('/')[1].split(',')[0]
      city = year_month_city.split('/')[1].split(',')[1]
      options[:compare]=[year,month,city]
    else
      puts "Year Month and City are required with -c flag"
    end
  end
end.parse!

if options[:exact]
  year,city = options[:exact]
  puts "Fetching weather data for #{city} in the year #{year}..."
  months_array=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
  master={}
  tempH=-10000
  tempL= 10000
  humid=-10000
  months_array.each_with_index do |month,index|
    str = "#{city.capitalize}_weather\\#{city.capitalize}_weather_#{year}_#{month.capitalize}.txt"
    # puts str
  # str = "Dubai_weather\\Dubai_weather_2014_Oct.txt"
    begin
      CSV.foreach(str,headers:true) do |row|
        if row["Max TemperatureC"].to_i>=tempH
          tempH=row["Max TemperatureC"].to_i
          master[:max]=row
        end
        if row["Min TemperatureC"].to_i<tempL
          tempL=row["Min TemperatureC"].to_i
          master[:low]=row
        end
        if row[" Mean Humidity"].to_f>humid
          humid=row[" Mean Humidity"].to_f
          master[:humid]=row
        end
      end
    rescue
      puts "Caught Error in index : #{index}"
      return
    end
   
  end
  # puts master
  puts "-"*50
  begin
    puts "Highest was #{master[:max]["Max TemperatureC"]}C on #{months_array[master[:max]["GST"].split('-')[1].to_i-1]} #{master[:max]["GST"].split('-')[2]}"
  rescue
    puts "Highest was #{master[:max]["Max TemperatureC"]}C on #{months_array[master[:max]["PKST"].split('-')[1].to_i-1]} #{master[:max]["PKST"].split('-')[2]}"
  end
  begin
    puts "Lowest was #{master[:low]["Min TemperatureC"]}C on #{months_array[master[:low]["GST"].split('-')[1].to_i-1]} #{master[:low]["GST"].split('-')[2]}"
  rescue  
    puts "Lowest was #{master[:low]["Min TemperatureC"]}C on #{months_array[master[:low]["PKST"].split('-')[1].to_i-1]} #{master[:low]["PKST"].split('-')[2]}"
  end
  begin  
    puts "Humidity: #{master[:humid][" Mean Humidity"]}% on #{months_array[master[:low]["GST"].split('-')[1].to_i-1]} #{master[:low]["GST"].split('-')[2]}"
    puts "-"*50
  rescue
    puts "Humidity: #{master[:humid][" Mean Humidity"]}% on #{months_array[master[:low]["PKST"].split('-')[1].to_i-1]} #{master[:low]["PKST"].split('-')[2]}"
    puts "-"*50
  end

elsif options[:average]
  # puts options[:average]
  #for a given month display the average highest temp, avg lowest temp, avg humidity
  str = "#{options[:average][2].capitalize}_weather\\#{options[:average][2].capitalize}_weather_#{options[:average][0]}_#{options[:average][1].capitalize}.txt"
  puts str
  begin
    data= CSV.read(str,headers:true)
    highest_temperature = []
    lowest_temperature = []
    humidity=[]
    data.each do |row|
      highest_temperature.append(row['Max TemperatureC'].to_f)
      lowest_temperature.append(row['Min TemperatureC'].to_f)
      humidity.append(row[' Mean Humidity'].to_f)
    end

    puts "-"*20
    puts "Average Highest Temperature : #{(highest_temperature.sum()/highest_temperature.length).to_i}C Average Lowest Temperature : #{(lowest_temperature.sum()/lowest_temperature.length).to_i}C Average Humidity : #{(humidity.sum/humidity.length).to_i}%"
    puts "-"*20

  rescue
    puts "Invalid arguments"
  end

elsif options[:compare]
  puts options
  str = "#{options[:compare][2].capitalize}_weather\\#{options[:compare][2].capitalize}_weather_#{options[:compare][0]}_#{options[:compare][1].capitalize}.txt"
  puts str
  begin
    data= CSV.read(str,headers:true)
    data.each_with_index do |row,index|
      print "#{index} "
      print "+".red* row['Max TemperatureC'].to_i
      puts " #{row['Max TemperatureC'].to_i}C"

      print "#{index} "
      print "+".blue* row['Min TemperatureC'].to_i
      puts " #{row['Min TemperatureC'].to_i}C"
    end
  rescue
    puts "Invalid input arguments"
  end

elsif options[:high_low]
  puts options
  str = "#{options[:high_low][2].capitalize}_weather\\#{options[:high_low][2].capitalize}_weather_#{options[:high_low][0]}_#{options[:high_low][1].capitalize}.txt"
  puts str
  begin
    data= CSV.read(str,headers:true)
    data.each_with_index do |row,index|
      print "#{index} "
      print "+".red* row['Max TemperatureC'].to_i
      print "+".blue* row['Min TemperatureC'].to_i
      print " #{row['Max TemperatureC'].to_i}C -"
      puts " #{row['Min TemperatureC'].to_i}C"
    end
  rescue
    puts "Invalid input arguments"
  end
else
  puts "Invalid option. Use -h or --help for usage information."
end
