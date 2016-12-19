function isPPN (value) {
	if (value.match(/^[0-9X]{9}/)) return true;
};

function getFirstValueByXPath (xml,path) {
	/*function nsResolver(prefix) {
		return 'http://www.loc.gov/mods/v3';
	}*/
	// Problems with default namespaces see https://developer.mozilla.org/en-US/docs/Introduction_to_using_XPath_in_JavaScript#Using_XPath_functions_to_reference_elements_with_a_default_namespace
	var nsResolver = xml.createNSResolver( xml.documentElement );
	xPathRes = xml.evaluate(path, xml, nsResolver, XPathResult.ANY_TYPE, null);
	//xPathRes = xml.evaluate(path, xml, null, XPathResult.ANY_TYPE, null);
	node = xPathRes.iterateNext();
	if (node) {
		if ($(node).text() != "" && $(node).text() != undefined) {
			return($(node).text());
		} else {
			return(node.value);
		}
	}
	return null;
};

function mods2Preview(xml) {
    
    title = $(xml).find( "title" ).html();
    publisher = $(xml).find( "publisher" ).html();
    html  = '<div style="margin-left:15px">';
    html += '<strong>' + title + '</strong> <br/>' ;
    html +=  publisher + '<br/>' ;
    html += '</div>';
	$('#PPNPreview').html(html);
};

function checkPPNValue() {
	value = $('#PPN').val();
	if (isPPN (value)) {
		$('#PPNPreview').html('<div style="text-align:center;color:gray;" ><i class="fa fa-spinner" aria-hidden="true"></i> <br/> PPN wird geladen </div>');
		
		$.ajax({
  			method: "GET",
			url: "http://unapi.gbv.de/?format=mods36&id=gvk:ppn:"+value,
			dataType: "xml"
		}) .done(function( xml ) {
			mods2Preview(xml);
			$('#sourceuri').val('http://unapi.gbv.de/?format=mods36&id=gvk:ppn:'+value);
		}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
			if(jqXHR.status==404) {
			    var html='<div style="text-align:center;color:red;" >'+jqXHR.responseText+'</div>';
        		$('#PPNPreview').html(html);
    		} else {
    			$('#PPNPreview').html("Unknown Error");
    		}
  		});
	} else {
		$('#PPNPreview').html('<div style="text-align:center;color:gray;" >Bitte PPN eingeben.</div>');
	}
};

$(document).ready( function() {
	
	checkPPNValue();
	$('#PPN').keyup(function (){checkPPNValue();});
	$('#PPN').change(function (){checkPPNValue();});
});