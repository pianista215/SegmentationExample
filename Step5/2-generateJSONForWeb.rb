#Generate the Javascript we will use in the web template generated
require "mongo"
require "csv"
require "json"

#Disable mongo logs
Mongo::Logger.logger.level = Logger::ERROR

#Connect to Mongo
mongo_client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'segmentationExample')

#First fill the countries.js
File.open("web/countries.js", "w") do |f|
	f.puts("var countries = [")
	CSV.foreach('../step3/countriesPresent.csv') do |row|
		f.puts("{")
		f.puts('"lat":' + row[0].to_s + ",")
		f.puts('"lon":' + row[1].to_s + ",")
		f.puts('"name":' + row[2].to_s)
		f.puts("},")
	end
	f.puts("];")
end

#Second fill the reg_params
#Retrieve previous calculated normalization parameters
norm_parameters = nil
mongo_client[:normalizationTerms].find().limit(1).each do |p|
	norm_parameters = p
end

File.open("web/norm.js", "w") do |f|
	f.puts("var norm = {};")
	f.puts("norm.adults_mean = " + norm_parameters["adults_mean"].to_s + ";")
	f.puts("norm.adults_dif = " + norm_parameters["adults_dif"].to_s + ";")
	f.puts("norm.children_mean = " + norm_parameters["children_mean"].to_s + ";")
	f.puts("norm.children_dif = " + norm_parameters["children_dif"].to_s + ";")
	f.puts("norm.lat_mean = " + norm_parameters["lat_mean"].to_s + ";")
	f.puts("norm.lat_dif = " + norm_parameters["lat_dif"].to_s + ";")
	f.puts("norm.lon_mean = " + norm_parameters["lon_mean"].to_s + ";")
	f.puts("norm.lon_dif = " + norm_parameters["lon_dif"].to_s + ";")
end

#Third fill the tops
last_segment = nil
File.open("web/tops.js", "w") do |f|
	f.puts("var tops = [")
	CSV.foreach('top.csv') do |row|
		if last_segment == nil
			f.puts('"segment":' + row[0].to_s + ",")
			f.puts('"top": [')
			f.puts("{")
			f.puts('"code": "' + row[1].to_s + '",')
			f.puts('"count": "' + row[2].to_s + '"')
			f.puts("},")
			last_segment = row[0]
		elsif last_segment == row[0] # Same segment
			f.puts("{")
			f.puts('"code": "' + row[1].to_s + '",')
			f.puts('"count": "' + row[2].to_s + '"')
			f.puts("},")
		else
			f.puts('],')
			ast_segment = nil
			f.puts('"segment":' + row[0].to_s + ",")
			f.puts('"top": [')
			f.puts("{")
			f.puts('"code": "' + row[1].to_s + '",')
			f.puts('"count": "' + row[2].to_s + '"')
			f.puts("},")
			last_segment = row[0]
		end
	end
	f.puts("];")
end