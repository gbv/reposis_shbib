
function getDuplicates() {
	searchfield = $('[data-duplicate-searchfield]').attr('data-duplicate-searchfield');
	if (searchfield) {
		
		
		var solrURL = webApplicationBaseURL + "/servlets/solr/select?q=*%3A*&rows=0&fl=id&wt=json&indent=true&facet=true&facet.field=" + searchfield;
    	$.ajax({
  			method: "GET",
			url: solrURL,
			dataType: "json"
		}) .done(function( json ) {
		    var html="<ul>";
		    var i = 0;
		    var facets=json['facet_counts']['facet_fields']['recordIdentifier'];
		    while (facets[i] && facets[i+1]) {
		    	ppn=facets[i];
		    	count=facets[i+1];
		    	link= webApplicationBaseURL + "/servlets/solr/select?q=%2BobjectType%3A%22mods%22+%2BrecordIdentifier%3A%22" + ppn + "%22&fl=*%2Cscore&rows=20";
		    	html += '<li> <a href="' + link + '">' + ppn + '-' + count + '</a> </li>';
		    	i=i+2;
		    }
		    
    
	    	html+="</ul>"; 
	    	$('[data-duplicate-searchfield]').html(html);
		}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
			if(jqXHR.status==404) {
			    var html='<div style="text-align:center;color:red;" >'+jqXHR.responseText+'</div>';
       			$('[data-duplicate-searchfield]').html(html);
    		} else {
    			$('[data-duplicate-searchfield]').html("Unknown Error during get FacetSearch");
    		}
  		});
	
	} 
};

$(document).ready( function() {
	//var  $("[data-duplicate-searchfield]");
	//if ($('#PPN'))
	getDuplicates();
});