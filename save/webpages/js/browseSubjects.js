var RowsPerPage = 20;

function escapeSearchvalue(text) {
  var map = {
    ' ': '\\ ',
    '(': '\\(',
    ')': '\\)'
    
  };
  return text.replace(/[ ()]/g, function(m) { return map[m]; });
}

function escapeHtml(text) {
  var map = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };

  return text.replace(/[&<>"']/g, function(m) { return map[m]; });
}

function getSearchfunction(Query,Start,Rows) {
	var str = 'searchSubjects(&#039;' + escapeHtml(Query) + '&#039;,' + Start + ',' +  Rows + '); return false;';
	return (str);
}

function showresult(json) {
    
    var Query = json.responseHeader.params.q;
    var Start = json.responseHeader.params.start;
    var Rows = json.responseHeader.params.rows;
    var NumFound = json.response.numFound;
    var SubjectType = '';
    if (json.responseHeader.params.fq && json.responseHeader.params.fq.substring(0,11) == 'subjectType'  ){
    	var SubjectType = json.responseHeader.params.fq.substring(12);
    } 
    var FQuery = '';
    if (json.responseHeader.params.fq){
    	var FQuery = json.responseHeader.params.fq;
    } 
    
    var html="";
    $.each(json.response.docs, function (index,doc) {
        length = ('mycoreid' in doc) ? doc.mycoreid.length : 0; 
        searchlink = webApplicationBaseURL + 'servlets/solr/select?q=mods.subject%3A%22\\' + doc.displayForm + '%22&wt=xml';
        html += '<li> ';
        html += '<a title="Suche nach allen Publikationen" href="' + searchlink + '" >';
        html +=  doc.displayForm ; //+ ' (' + length + ')';
        html +=  '</a>';
        html +=  '</li>';
    });
    html+="";
    $('#resultList').html(html);
    
    html="";
    
    var CountPages = Math.trunc (NumFound / Rows) +1;
    var ActualPage = Math.trunc (Start / Rows) + 1;
    var Startpage,EndPage;
    if (ActualPage < 5) {
    	StartPage = 1;
    	if (CountPages < 7) {
    		EndPage = CountPages;
    	} else {
    		EndPage = 7;
    	}
    } else if (ActualPage > (CountPages - 5)) {
    	StartPage = CountPages-6;
    	EndPage = CountPages;
    } else {
    	StartPage = ActualPage-3;
    	EndPage = ActualPage+3;
    }
    
    PagQuery = Query;
    if (FQuery != '') PagQuery += '&fq='+FQuery;
    html+=' <ul class="pagination pagination-sm" id="solr-result-paginate">';
    if (ActualPage > 1) {
    	html+='   <li>';
    	html+='     <a title="erste Seite" href="javascript:void(0)" onclick="' + getSearchfunction(PagQuery,0,Rows)  + '">«<span class="sr-only">erste Seite</span></a>';
    	html+='   </li>';
    } else {
    	html+='   <li class="disabled">';
    	html+='     <span>«<span class="sr-only">erste Seite</span></span>';
    	html+='   </li>';
    }
    if (ActualPage > 1) { 
    	html+='   <li class="disabled">';
    	html+='     <a title="vorherige Seite" tabindex="0" href="javascript:void(0)" onclick="' + getSearchfunction(PagQuery,(ActualPage -1)*Rows,Rows)  + '">‹<span class="sr-only">vorherige Seite</span></a>';
    	html+='   </li>';
    } else {
       	html+='   <li class="disabled">';
    	html+='     <span>‹<span class="sr-only">vorherige Seite</span></span>';
    	html+='   </li>';
    }
    for (var i = StartPage; i <= EndPage ; i++) {
    	var active = ((i == ActualPage) ? 'class="active"' : '');
    	html+='   <li ' + active + ' >';
    	if (i == ActualPage) {
    		html+='     <span>' + i + '</span>';
    	} else {
    		html+='     <a tabindex="0" href="javascript:void(0)" onclick="' + getSearchfunction(PagQuery,(i-1)*Rows,Rows)  + '">' + i + '</a>';
    	}
    	html+='   </li>';
   	}
    if (ActualPage < CountPages) {
    	html+='   <li>';
    	html+='     <a title="nächste Seite" href="javascript:void(0)" onclick="' + getSearchfunction(PagQuery,0,Rows)  + '">›<span class="sr-only">nächste Seite</span></a>';
    	html+='   </li>';
    } else {
    	html+='   <li class="disabled">';
    	html+='     <span>›<span class="sr-only">nächste Seite</span></span>';
    	html+='   </li>';
    }
    if (ActualPage < CountPages) { 
    	html+='   <li class="disabled">';
    	html+='     <a title="letzte Seite" tabindex="0" href="javascript:void(0)" onclick="' + getSearchfunction(PagQuery,(CountPages -1)*Rows,Rows)  + '">»<span class="sr-only">letzte Seite</span></a>';
    	html+='   </li>';
    } else {
       	html+='   <li class="disabled">';
    	html+='     <span>»<span class="sr-only">letzte Seite</span></span>';
    	html+='   </li>';
    }
	
    $('#resultListPagination').html(html);
    
    html='';
    html+='<div class="panel panel-default">';
    html+='  <div  class="panel-heading">';
    html+='    <h3 class="panel-title">Schlagworttyp</h3>';
    html+='  </div>';
    html+='  <div class="panel-body">';
    html+='    <ul class="filter">';
    
    for (var i = 0; i < json.facet_counts.facet_fields.subjectType.length; i=i+2) {
       	facet = json.facet_counts.facet_fields.subjectType[i];
    	facetCount = json.facet_counts.facet_fields.subjectType[i+1];
    	var FacetQuery = Query; 
    	var checked='';
    	if (SubjectType == facet) {
    		checked='checked="true"';
    	} else {
    		FacetQuery += '&fq=subjectType:' + facet;
    	}
    	
    	html+='      <li>';
    	html+='        <div class="checkbox">';
    	html+='          <label>';
    	html+='            <input ' + checked + ' onclick="' + getSearchfunction(FacetQuery,0,Rows) + '" type="checkbox">';
    	html+='          </label>';
    	html+='          <span class="title">' + facet + '</span>';
    	html+='          <span class="hits">' + facetCount + '</span>';
    	html+='        </div>';
    	html+='      </li>';
    };
    
    html+='    </ul>';
    html+='  </div>';
    html+='</div>';
    
    $('#subjectFacets').html(html);
    
};

function searchSubjects(Query,Start,Rows) {
	$.ajax({
  		method: "GET",
		url: webApplicationBaseURL + "/solrsubjectproxy/select?q=" + Query + "&wt=json&start=" + Start + "&rows=" + Rows + "&indent=true&sort=displayForm+asc&facet=true&facet.field=subjectType",
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
	searchSubjects(query,0,20);
	
	$('#subjectSearch_submit').click( function () {
	    var searchValue = $('#subjectSearch_subject').val();
	    var squery = "";
	    if ($('#subjectSearch-typ-part').prop("checked") ) {
	    	$.each (searchValue.split(" "), function (key, value) {
	    		squery += "suggest:*" + escapeSearchvalue(value) +"*+AND+"; 
	    	});
	    	squery = squery.substring(0, squery.length - 4);
	    } else {
	        squery= "suggest:" + escapeSearchvalue(searchValue) +"*";
	    }
	    var onlyWithMIDs = 'mycoreid:[""+TO+*]';
		searchSubjects( "(" + squery + ")AND("+onlyWithMIDs+")",0,20);
	});
	
});