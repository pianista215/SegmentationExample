#Now our data is normalized, we are going to select radomly K clusters to make the segmentation

require 'mongo'

#Disable mongo logs
Mongo::Logger.logger.level = Logger::ERROR

#Connect to Mongo
mongo_client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'segmentationExample')

#Delete previous data
mongo_client[:centroids].drop()

#There'is different ways to select the optimal number of clusters, we are going to use the "by hand" method, estimating 3 clusters per country
CLUSTERS_NUM = 75 * 3

#Get different rows (If we have choose too clusters raise an exception)
#We have to ensure that each row to be elected is unique, because if not, we will have two initial clusters with the same data
=begin
Mongo query:
db.segmented.aggregate(
	{ "$group":
	{ "_id" : { "adults" : "$adults" , "children" : "$children" , "lat" : "$lat" , "lon" : "$lon"} , "count" : { "$sum" : 1}}
	}
)
=end
rows = mongo_client[:segmented].find.aggregate([
	{ :$group=>
		{ :_id => { :adults => "$adults" , 
					:children => "$children" , 
					:lat => "$lat" , 
					:lon => "$lon"} , 
		:count => { :$sum => 1}}
	}
])


different_examples = rows.count

if different_examples < CLUSTERS_NUM
	raise "Too much CLUSTERS for few different training examples"
end

#Radomly assign the each centroid in a different training example
centroids_ids = (1..different_examples).to_a.shuffle.shuffle.slice(0..CLUSTERS_NUM-1)

#Retrieve one training example that have the data of the different example selected
idx = 0
idx_segment = 1
centroids = []
rows.each do |document|
	if centroids_ids.include? idx
		centroids.push({
			"adults" => document["_id"]["adults"],
			"children" => document["_id"]["children"],
			"lat" => document["_id"]["lat"],
			"lon" => document["_id"]["lon"],
			"segment" => idx_segment
		})
		idx_segment = idx_segment + 1 
	end
	idx = idx + 1 
end

centroids.each do |centroid|
	#Insert into the centroids database as initial cluster centroids
	mongo_client[:centroids].insert_one({
			"adults" => centroid["adults"],
			"children" => centroid["children"],
			"lat" => centroid["lat"],
			"lon" => centroid["lon"],
			"segment" => centroid["segment"]
	})
end