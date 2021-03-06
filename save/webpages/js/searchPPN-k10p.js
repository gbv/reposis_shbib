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

function showHintNoDoc (ppn) {
    var html;
    html  = '<div class="alert alert-warning" role="alert">';
    html += '  Der übergeordnete Titel ist im System noch nicht aufgenommen worden. <br/>';
    html += '  <a href="' + webApplicationBaseURL + '/editor/editor-ppnsource.xed?ppn='+ ppn +'"> Jetzt aufnehmen </a>';
    html += '</div>';
    $('#ppn-warning').html(html);
}

function showHintToMuchDoc (ppn,solrURL) {
    solrURL = solrURL.replace("&XSL.Style=xml", "");
    var html;
    html  = '<div class="alert alert-danger" role="alert">';
    html += '  Die Suche hat mehrere Kandidaten für den übergeordneten Titel gefunden.  <br/>';
    html += '  <a href="'+solrURL+'"> Liste </a>';
    html += '</div>';
    $('#ppn-warning').html(html);
}

function showHintDocExsist(ppn,solrURL,numFound) {
	solrURL = solrURL.replace("&XSL.Style=xml", "");
    var html;
    html  = '<div class="alert alert-danger" role="alert">';
    html += '  ' + numFound + ' Dokument mit der PPN wurde schon erfasst.  <br/>';
    html += '  <a href="'+solrURL+'"> Liste </a>';
    html += '</div>';
    $('#PPNPreview').html(html);
}


function checkRelatedItem(ppn) {
    var solrURL = webApplicationBaseURL + "/servlets/solr/select?q=mods.identifier%3A*PPN%3D" + ppn + "&wt=xml&XSL.Style=xml";
    var cppn = ppn; 
    $.ajax({
  		method: "GET",
		url: solrURL,
		dataType: "xml"
	}) .done(function( xml ) {
	    var numFound = $(xml).find('result[name="response"]').attr("numFound");
	    if (numFound == 0) {
	        showHintNoDoc(cppn);
	    } else if (numFound > 1) {
	        showHintToMuchDoc(ppn,solrURL);
	    } 
	}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
		if(jqXHR.status==404) {
		    var html='<div style="text-align:center;color:red;" >'+jqXHR.responseText+'</div>';
       		$('#PPNPreview').html(html);
    	} else {
    		$('#PPNPreview').html("Unknown Error during get relatedItem");
    	}
  	});

}

function mods2Preview(xml) {
    
    var title = $(xml).find( "title" ).text();
    var publisher = $(xml).find( "publisher" ).text();
    var authors = [];
    $(xml).find( 'name' ).each ( function( index, name ) {
        var role = $(name).find ('roleTerm [authority="marcrelator"]').text();
        var givenName = $(name).find('namePart[type="given"]').text();
        var familyName = $(name).find('namePart[type="family"]').text();
        if (role='aut') authors.push( givenName + ' ' + familyName );
    });
    var relatedItemPPN = null; 
    $(xml).find('relatedItem[type="host"] > identifier ').each ( function (index, identifier ) {
        var text = $(identifier).text();
        if (text.substring(0, 8) == "(DE-601)") {
            relatedItemPPN=text.substring(8);
        };
    });
    
    html  = '<div id="ppn-warning"> </div>';
    html += '<div style="margin-left:15px">';
    html += '<strong>' + title + '</strong> <br/>' ;
    $.each(authors, function( index, author ) {
        html += author + ";";
    });
    html +=  '<br/>' ;
    html +=  publisher + '<br/>' ;
    html += '</div>';
	$('#PPNPreview').html(html);
	
	if (relatedItemPPN !== null) checkRelatedItem(relatedItemPPN);
};

function loadFromUNAPI(ppn) {
	$.ajax({
  		method: "GET",
		url: webApplicationBaseURL + "/unapiproxyk10p/?format=mods36&id=gvk:ppn:"+ppn,
		dataType: "xml"
	}) .done(function( xml ) {
		mods2Preview(xml);
	}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
		if(jqXHR.status==404) {
		    var html='<div style="text-align:center;color:red;" >'+jqXHR.responseText+'</div>';
       		$('#PPNPreview').html(html);
    	} else {
    		$('#PPNPreview').html("Unknown Error");
    	}
  	});
}

function checkPPNValue() {
	ppn = $('#PPN').val();
	mycoreid = $("input[name='id']").val();
	$('#sourceuri').val('http://unapi.k10plus.de/?format=picaxml&id=gvk:ppn:'+ppn);
	if (isPPN (ppn)) {
		
		$('#PPNPreview').html('<div style="text-align:center;color:gray;" ><i class="fa fa-spinner" aria-hidden="true"></i> <br/> PPN wird geladen </div>');
	
		//var solrURL = webApplicationBaseURL + "/servlets/solr/select?q=mods.identifier%3A*PPN%3D" + ppn + "+-id%3A" + mycoreid + "&wt=xml&XSL.Style=xml";
		var solrURL = webApplicationBaseURL + "/servlets/solr/select?q=mods.identifier%3A*PPN%3D" + ppn + "+-id%3A" + mycoreid + "&wt=xml&XSL.Style=xml";
    	$.ajax({
  			method: "GET",
			url: solrURL,
			dataType: "xml"
		}) .done(function( xml ) {
		    var numFound = $(xml).find('result[name="response"]').attr("numFound");
	    	if (numFound == 0) {
		        loadFromUNAPI(ppn);
		    } else if (numFound >= 1) {
	    	    showHintDocExsist(ppn,solrURL,numFound);
	    	} 
		}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
			if(jqXHR.status==404) {
			    var html='<div style="text-align:center;color:red;" >'+jqXHR.responseText+'</div>';
       			$('#PPNPreview').html(html);
    		} else {
    			$('#PPNPreview').html("Unknown Error during get relatedItem");
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