
function showresult(json) {
    
    var html="";
    $.each(json.response.docs, function (index,doc) {
        length = ('mycoreid' in doc) ? doc.mycoreid.length : 0; 
        searchlink = 'https://reposis-test.gbv.de/shbib/servlets/solr/select?q=subjectid%3A\\' + doc.id + '&wt=xml';
        html += '<li> ';
        html += '<a title="Suche nach allen Publikationen" href="' + searchlink + '" >';
        //html +=  doc.displayForm + ' (' + length + ')';
        html +=  '</a>';
        html +=  '</li>';
    });
    html+="";
    
    $('#resultList').html(html);
	
};

function search(Query) {
	$.ajax({
  		method: "GET",
		url: webApplicationBaseURL + "/solrsubjectproxy/select?q=" + Query + "&wt=json&indent=true&sort=displayForm+asc",
		dataType: "json"
	}) .done(function( json ) {
		showresult(json);
	}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
		if(jqXHR.status==404) {
		    console.log('Error while reading data from Index' + jqXHR.responseText);
       	} else {
    		console.log('Error while reading data from Index');
    	}
  	});
};

$(document).ready( function() {
	
	var query = 'mycoreid:[""+TO+*]';
	search(query);
	
});