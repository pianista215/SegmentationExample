#We are going to use the market as a feature in our segmentation algorithm
#As I consider that the markets may be are affected by It's position, I will use the coordinates as features
#If you don't think so, may be you should code with indexes(1,2,3...) each market
#You must install the mongodb driver for ruby to have this code working: 
#https://github.com/mongodb/mongo-ruby-driver/wiki/Tutorial
#https://github.com/oneclick/rubyinstaller/wiki/Development-Kit
#(If you have problem installing the gem of mongo try: gem update --system 2.3.0)
#For problems with bson_ext in windows: http://stackoverflow.com/questions/26092541/windows-rails-error-installing-bson-ext
#Install Google maps API https://developers.google.com/api-client-library/ruby/apis/coordinate/v1

require 'mongo'
require 'json'

#Disable mongo logs
Mongo::Logger.logger.level = Logger::ERROR


#Thanks http://www.ohadpr.com/2010/04/countries-approximate-lat-lon-and-iso-3166-1-alpha-2/
#Get coordinates from JSON file for each country appeared in the database
file = File.read('countriesCodes.json')
countriesCoords = JSON.parse(file)

#Connect to Mongo
mongo_client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'segmentationExample')

#Remove old data
mongo_client[:geopositionated].drop()

#Create each entry with the coordinates
mongo_client[:initial].find().each do |document|
	country = countriesCoords[document["COUNTRY"]]
	if country == nil
		#Ensure our JSON is complete (I've added United Kingdom)
		raise "Country coordinate not found:"+document["COUNTRY"]
	else
		#Insert into a new collection (You can use the same initial collection, but to have a more clear vision, use another collection)
		mongo_client[:geopositionated].insert_one({
				"id" => document["BOOKING"],
				"product" => document["PRODUCT_KEY"],
				"adults" => document["ADULTS"],
				"children" => document["CHILDREN"],
				"lat" => country[0],
				"lon" => country[1]
		})
	end
end





