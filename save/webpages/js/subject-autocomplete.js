var engines2 = {
	subjectSuggest : {
		engine : new Bloodhound({
			// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
			datumTokenizer : Bloodhound.tokenizers.obj.whitespace('displayForm'),
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'solrsubjectproxy/suggest?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.suggest.default;
					var returnList = [];
					$.each(list, function(index, item) {
					    $.each(item.suggestions, function(index2, item2) { 
					        var returnListItem = new Object();
					        returnListItem.name = item2.term;
					        returnListItem.value = jQuery('<p>' + item2.term + '</p>').text();
					        returnList.push(returnListItem);
					    } );
					});
					return returnList;
				},
				prepare : function(query, settings) {
				    
					var param = "suggest.q=" + query + "&wt=json&indent=true";
					
					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		})
	},
	topicSuggest : {
		engine : new Bloodhound({
			// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
			datumTokenizer : Bloodhound.tokenizers.obj.whitespace('displayForm'),
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'solrsubjectproxy/select?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.response.docs;
					$.each(list, function(index, item) {
						item.name = item['displayForm'];
						item.value = item['displayForm'];
					});
					return list;
				},
				prepare : function(query, settings) {
				    
					var param = "q=displayForm%3A" + query + "*+AND+subjectType%3A+topic";
					param += "&wt=json&indent=true&rows=1000";
					
					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		})
	},
	geographicSuggest : {
		engine : new Bloodhound({
			// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
			datumTokenizer : Bloodhound.tokenizers.obj.whitespace('displayForm'),
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'solrsubjectproxy/select?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.response.docs;
					$.each(list, function(index, item) {
						item.name = item['displayForm'];
						item.value = item['displayForm'];
					});
					return list;
				},
				prepare : function(query, settings) {
				    
					var param = "q=displayForm%3A" + query + "*+AND+subjectType%3A+geographic";
					param += "&wt=json&indent=true&rows=1000";
					
					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		})
	},
	personalSuggest : {
		engine : new Bloodhound({
			// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
			datumTokenizer : Bloodhound.tokenizers.obj.whitespace('displayForm'),
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'solrsubjectproxy/select?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.response.docs;
					$.each(list, function(index, item) {
						item.name = item['displayForm'];
						item.value = item['displayForm'];
					});
					return list;
				},
				prepare : function(query, settings) {
				    
					var param = "q=displayForm%3A" + query + "*+AND+subjectType%3A+personal";
					param += "&wt=json&indent=true&rows=1000";
					
					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		})
	},
	corporateSuggest : {
		engine : new Bloodhound({
			// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
			datumTokenizer : Bloodhound.tokenizers.obj.whitespace('displayForm'),
			queryTokenizer : Bloodhound.tokenizers.whitespace,
			remote : {
				url : webApplicationBaseURL + 'solrsubjectproxy/select?%QUERY',
				wildcard : '%QUERY',
				transform : function(list) {
					list = list.response.docs;
					$.each(list, function(index, item) {
						item.name = item['displayForm'];
						item.value = item['displayForm'];
					});
					return list;
				},
				prepare : function(query, settings) {
				    
					var param = "q=displayForm%3A" + query + "*+AND+subjectType%3A+corporate";
					param += "&wt=json&indent=true&rows=1000";
					
					settings.url = settings.url.replace("%QUERY", param);
					return settings;
				}
			}
		})
	},
	empty : {
		engine : new Bloodhound(
				{
					// datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
					datumTokenizer : Bloodhound.tokenizers.obj.whitespace('mods.title[0]'),
					queryTokenizer : Bloodhound.tokenizers.whitespace,
					remote : {
						url : webApplicationBaseURL
								+ 'servlets/solr/select?&q=%2Bmods.title%3A*%QUERY*+%2Bcategory.top%3A%22mir_genres\%3Aseries%22+%2BobjectType%3A%22mods%22&version=4.5&rows=1000&fl=mods.title%2Cid%2Cmods.identifier&wt=json',
						transform : function(list) {
							return {};
						}
					}
				}),
		displayText : function(item) {
			return item;
		}
	}
};

$(document).ready(function() {

	$("input[data-provide='typeahead'].subjectSuggest").each(function(index, input) {
		var Engine;
		if (engines2[$(this).data("searchengine")]) {
			Engine = engines2[$(this).data("searchengine")];
		} else {
			Engine = engines2["empty"];
		}
		Engine.engine.initialize();
		$(this).typeahead({
			items : 7,
			source : function(query, callback) {
				// rewrite source function to work with newer typeahead version
				// @see (withAsync(query, sync, async))
				var func = Engine.engine.ttAdapter();
				return $.isFunction(func) ? func(query, callback, callback) : func;
			},
			updater : function(current) {
				current.name = current.value;
				return (current);
			},
			afterSelect : function(current) {
				// TO DO

			},
			highlighter: function (obj) {
				return (obj);
 			}
		});

	});

	

});



