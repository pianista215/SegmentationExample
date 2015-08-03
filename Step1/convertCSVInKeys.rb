require 'csv'

actualId = 0
productDicc = []

File.open("CSVInKeys.csv", "w") do |f|
	CSV.foreach('procesadoExcel.csv') do |row|
		#Ignore head
		if actualId == 0
			f.puts(row[0] + "," + row[1] + "," + row[2] + "," + row[3] + "," + row[4] + "," + row[5])
		else
			rowStr = actualId.to_s + ","
			
			#Convert to a dictionary id (The product key)
			idx = productDicc.index(row[1])
			if idx == nil
				productDicc.push(row[1])
				rowStr += productDicc.length.to_s
			else
				rowStr += idx.to_s
			end

			#Maintain the rest of values
			rowStr += "," + row[2] + "," + row[3] + "," + row[4] + "," + row[5]
			f.puts(rowStr)
		end
		actualId = actualId+1
	end
end

