function compareIndexedWithAllObjects(indexedObjects) {
	var restapiURL = webApplicationBaseURL + "/api/v1/objects?format=json";
    $.ajax({
  		method: "GET",
		url: solrURL,
		dataType: "json"
	}) .done(function( json ) {
	    var allObjects = json;
	    var html = "";
	    $.each( allObjects, function (elem) {
	    	html += "elem";
	    }); 
		$('[#nonindexedTitles]').html(html);
	}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
		if(jqXHR.status==404) {
		    var html='<div style="text-align:center;color:red;" >'+jqXHR.responseText+'</div>';
    		$('[#nonindexedTitles]').html(html);
    	} else {
    		$('[#nonindexedTitles]').html("Unknown Error during get ObjectIds from restapi");
    	}
  	});
}


function checkNoIndexedObjects() {
	var solrURL = webApplicationBaseURL + "/servlets/solr/select?q=%2BobjectType%3A%22mods%22&fl=id&rows=100000000
    $.ajax({
  		method: "GET",
		url: solrURL,
		dataType: "json"
	}) .done(function( json ) {
		compareIndexedWithAllObjects(json);
	}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
		if(jqXHR.status==404) {
		    var html='<div style="text-align:center;color:red;" >'+jqXHR.responseText+'</div>';
    		$('[#nonindexedTitles]').html(html);
    	} else {
    		$('[#nonindexedTitles]').html("Unknown Error during get ObjectIds from solr");
    	}
  	});
};

$(document).ready( function() {
	checkNoIndexedObjects();
});