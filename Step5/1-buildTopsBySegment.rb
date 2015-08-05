#Once we have segmented the data, we are going to build the top by products for each segmented
#We generate top.csv: a top of products for each segment (segment, product, count)
require 'mongo'
require 'csv'

#Disable mongo logs
Mongo::Logger.logger.level = Logger::ERROR

#Connect to Mongo
mongo_client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'segmentationExample')

=begin
Mongo query:
db.segmented.aggregate(
	{ "$group":
		{ "_id" : { "segment" : "$segment" , "product" : "$product"} , "count" : { "$sum" : 1}}
	},
	{ "$sort":
		{ "_id.segment": -1, "count": -1}
	}
)
=end
products = mongo_client[:segmented].find.aggregate([
	{ :$group =>
		{ :_id => { :segment => "$segment" , 
					:product => "$product" } ,
		  :count => { :$sum => 1}}
	}, 
	{ :$sort =>
		{ 
			"_id.segment" => 1,
		  	"count" => -1
		}
	}
])


#Write the CSV with the data ordered (try to put the equivalences if ..\step1\equivalences.csv exist)
equivalences = []
if File.exist?("../step1/equivalences.csv")
	CSV.foreach('../step1/equivalences.csv') do |row|
		equivalences.push({
			"id" => row[0],
			"real_code" => row[1]
		})
	end
end

File.open("top.csv", "w") do |f|
	products.each do |product|
		segment = product["_id"]["segment"].to_s
		code = product["_id"]["product"]
		count = product["count"].to_s
		if equivalences.length > 0
			#Equivalences are ordered by id assigned (id starts in)
			equivalence = equivalences[code-1]
			f.puts( segment + "," + equivalence["real_code"] + "," + count)
		else
			f.puts( segment + "," + code.to_s + "," + count)
		end
	end
end