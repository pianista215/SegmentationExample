#Our features will be: (adults, children, lat, lon)
#We are going to normalize all the variables because if not they won't have the same weight


require 'mongo'

#Disable mongo logs
Mongo::Logger.logger.level = Logger::ERROR

#Connect to Mongo
mongo_client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'segmentationExample')
total_rows = mongo_client[:geopositionated].find().count 

adults_mean = 0.0
adults_max = 0.0
adults_min = 0.0

children_mean = 0.0
children_max = 0.0
children_min = 0.0

lat_mean = 0.0
lat_max = 0.0
lat_min = 0.0

lon_mean = 0.0
lon_max = 0.0
lon_min = 0.0

#Create each entry with the coordinates
mongo_client[:geopositionated].find().each do |document|

	adults = document["adults"]
	adults_mean += adults
	if adults_max < adults
		adults_max = adults
	end
	if adults_min > adults
		adults_min = adults
	end

	children = document["children"]
	children_mean += children
	if children_max < children
		children_max = children
	end
	if children_min > children
		children_min = children
	end

	lat = document["lat"]
	lat_mean += lat
	if lat_max < lat
		lat_max = lat
	end
	if lat_min > lat
		lat_min = lat
	end

	lon = document["lon"]
	lon_mean += lon
	if lon_max < lon
		lon_max = lon
	end
	if lon_min > lon
		lon_min = lon
	end

end

adults_mean = adults_mean / total_rows
adults_dif = adults_max - adults_min

children_mean = children_mean / total_rows
children_dif = children_max - children_min

lat_mean = lat_mean / total_rows
lat_dif = lat_max - lat_min

lon_mean = lon_mean / total_rows
lon_dif = lon_max - lon_min

#We store that results into one collection
mongo_client[:normalizationTerms].drop()
mongo_client[:normalizationTerms].insert_one({
				"adults_mean" => adults_mean,
				"adults_dif" => adults_dif,
				"children_mean" => children_mean,
				"children_dif" => children_dif,
				"lat_mean" => lat_mean,
				"lat_dif" => lat_dif,
				"lon_mean" => lat_mean,
				"lon_dif" => lat_dif,
})
