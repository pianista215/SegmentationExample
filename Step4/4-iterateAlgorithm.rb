#Once we have created the initial centroids, we have to make n iterations to finally assign a segment
#If you want to change the initial centroids just execute again the 3-assignInitialClusters script of ruby
#An expansion could be make a graph to see how is evolving the algorithm (this can be accomplished easily in Matlab if you are doing the course)

require 'mongo'

ITERATIONS = 10

#Disable mongo logs
Mongo::Logger.logger.level = Logger::ERROR

#Connect to Mongo
mongo_client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'segmentationExample')

#Remove previous segments assigned
mongo_client[:segmented].find.update_many(
	"$unset" => {"segment"=>""}
)

#Get the initial centroids values
centroids = []
mongo_client[:centroids].find().each do |centroid|
	centroids.push(centroid)
end

#Write the centroids to a file to see how are evolutioning
File.open("initial_centroids.txt", "w") do |f|
	f.puts(centroids)
end

#To improve the performance we are going to store all the training examples in memory
training_examples = []
mongo_client[:segmented].find().each do |ex|
	training_examples.push(ex)
end


#Make the clustering algorithm
(1..ITERATIONS).each do |iteration|
	puts "Start Iteration:" + iteration.to_s
	#Assign each training example to it's near centroid
	training_examples.each do |ex|
		#Training data
		adults = ex["adults"]
		children = ex["children"]
		lat = ex["lat"]
		lon = ex["lon"]
		near_centroid = nil
		min_distance = nil

		centroids.each do |centroid|

			distance = (centroid["adults"]-adults)**2 + (centroid["children"]-children)**2 + (centroid["lat"]-lat)**2 + (centroid["lon"]-lon)**2

			if near_centroid == nil
				near_centroid = centroid
				min_distance = distance
			elsif distance < min_distance
				min_distance = distance
				near_centroid = centroid
			end
		end

		#Update with the new segment
		ex["segment"] = near_centroid["segment"]
	end

	#Reassign the centroids features to the mean of it's training examples
	centroids.each do |centroid|
		examples_count = 0
		adults_total = 0
		children_total = 0
		lat_total = 0
		lon_total = 0

		training_examples.each do |ex|
			if ex["segment"] == centroid["segment"]
				examples_count +=  1
				adults_total += ex["adults"]
				children_total += ex["children"]
				lat_total += ex["lat"]
				lon_total += ex["lon"]
			end
		end

		if examples_count == 0
			raise "Cluster without elements, may be you should reduce your number of clusters, or assign news radomly using the 3 script"
		end

		centroid["adults"] = adults_total / examples_count
		centroid["children"] = children_total / examples_count
		centroid["lat"] = lat_total / examples_count
		centroid["lon"] = lon_total / examples_count

	end

	#Save the new centroids values
	File.open("centroids_"+iteration.to_s+".txt", "w") do |f|
		f.puts(centroids)
	end

	puts "Ended Iteration:" + iteration.to_s
end

#Store the final centroids data
centroids.each do |centroid|
	mongo_client[:segmented].find(:_id => centroid["_id"]).update_one(
			"$set" => { 
				:adults => centroid["segment"],
				:children => centroid["children"],
				:lat => centroid["lat"],
				:lon => centroid["lon"],
			}
	)
end

#Store the final segment to all the examples
training_examples.each do |ex|
	mongo_client[:segmented].find(:_id => ex["_id"]).update_one(
			"$set" => { :segment => ex["segment"] }
	)
end

