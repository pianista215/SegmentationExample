#Now we have the parameters to normalize each var we create a collection with the normalized vars

require 'mongo'

#Disable mongo logs
Mongo::Logger.logger.level = Logger::ERROR

#Connect to Mongo
mongo_client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'segmentationExample')

norm_parameters = nil
#Retrieve previous calculated normalization parameters
mongo_client[:normalizationTerms].find().limit(1).each do |p|
	norm_parameters = p
end

#Erase old data segmented
mongo_client[:segmented].drop()

#Normalize the data and save into a new database
mongo_client[:geopositionated].find().each do |document|

	adults_normalized = (document["adults"] - norm_parameters["adults_mean"]) / norm_parameters["adults_dif"]
	children_normalized = (document["children"] - norm_parameters["children_mean"]) / norm_parameters["children_dif"]
	lat_normalized = (document["lat"] - norm_parameters["lat_mean"]) / norm_parameters["lat_dif"]
	lon_normalized = (document["lon"] - norm_parameters["lon_mean"]) / norm_parameters["lon_dif"]

	mongo_client[:segmented].insert_one({
		"id" => document["id"],
		"product" => document["product"],
		"adults" => adults_normalized,
		"children" => children_normalized,
		"lat" => lat_normalized,
		"lon" => lon_normalized
	})

end