(function($){

	$(document).ready(function(){
		loadCountries();
		$('#generate').on('click',function(){
			var adults = $('#adults').val();
			var children = $('#children').val();
			var country = $('#countries').val();
			var parts = country.split(";");
			var lat = parts[0];
			var lon = parts[1];
			changeSegment(adults, children, lat, lon);
		});
	});

	function loadCountries(){
		var str = "";
		for(var i=0;i<countries.length;i++){
			var country = countries[i];
			str += '<option value="'+country.lat+";"+country.lon+'">'+country.name+'</option>\n';
		}
		$('#countries').html(str);
	}

	function changeSegment(adults, children, lat, lon){
		var norm_adults = (adults - norm.adults_mean)/norm.adults_dif;
		var norm_children = (children - norm.children_mean)/norm.children_dif;
		var norm_lat = (lat - norm.lat_mean)/norm.lat_dif;
		var norm_lon = (lon - norm.lon_mean)/norm.lon_dif;

		var segment = getSegment(norm_adults, norm_children, norm_lat, norm_lon); 
		var top = getTop(segment);
		writeTopAndwidget(top);
		$('#segment').html(segment);
	}

	function getSegment(norm_adults, norm_children, norm_lat, norm_lon){
		var min_distance = null;
		var segment = null;

		for(var i=0;i<centroids.length;i++){
			var centroid = centroids[i];
			var distance = Math.pow(norm_adults-centroid.adults,2) + Math.pow(norm_children-centroid.children,2) + Math.pow(norm_lat-centroid.lat,2) + Math.pow(norm_lon-centroid.lon,2);

			if(min_distance==null){
				segment = centroid.segment;
				min_distance = distance;
			} else if(min_distance > distance){
				segment = centroid.segment;
				min_distance = distance;
			}
		}
		return segment;
	}

	function getTop(segment){
		return tops[segment-1]; //Segments starting in 1
	}

	function writeTopAndwidget(top){
		var str = "<tr><th>Activity Code</th><th>Count</th></tr>";
		codes = [];
		for(var i=0;i<top.top.length;i++){
			var curr = top.top[i];
			str += "<tr>";
			str += "<td>" + curr.code + "</td>";
			str += "<td>" + curr.count + "</td>";
			str += "</tr>";
			codes[codes.length] = curr.code;
		}
		$('#top').html(str);
		var widget = '<script type="text/javascript" src="http://wdgmul.hotelbeds.com/wdgfront/generator/widget.js" data-widget="true" data-userid="Jaalster" data-config="Jaalster_xselling_actividades" data-destinations="NYC"';
		widget += 'data-activitycodes="';
		for(var i=0; i < codes.length;i++){
			widget += codes[i];
			if(i!= codes.length-1){
				widget += ",";
			}
		}
		widget += '"';
		widget += '></script>';
		$('#widget').html(widget);
	}

})(jQuery);