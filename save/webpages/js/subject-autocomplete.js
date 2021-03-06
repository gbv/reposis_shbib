var engines2 = {
	subjectSuggest : {
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
					var squery = "";
					if ($('#subjectSearch-typ-part').prop("checked") ) {
				    	$.each (query.split(" "), function (key, value) {
				    	    squery += "suggest:*" + value +"*+AND+"; 
				        });
				        squery = squery.substring(0, squery.length - 6);
					} else {
						squery = "suggest%3A" + escapeSearchvalue(query) + "*";
					} 
					var param = "q=" + squery + "*+AND+mycoreid:[\"\"+TO+*]";
					param += "&wt=json&indent=true&rows=100";
					
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
				    
					var param = "q=displayForm%3A" + query + "*+AND+subjectType%3A+topic+AND+mycoreid:[\"\"+TO+*]";
					param += "&wt=json&indent=true&rows=100";
					
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
				    
					var param = "q=displayForm%3A" + query + "*+AND+subjectType%3A+geographic+AND+mycoreid:[\"\"+TO+*]";
					param += "&wt=json&indent=true&rows=100";
					
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
				    
					var param = "q=displayForm%3A" + query + "*+AND+subjectType%3A+personal+AND+mycoreid:[\"\"+TO+*]";
					param += "&wt=json&indent=true&rows=100";
					
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
				    
					var param = "q=displayForm%3A" + query + "*+AND+subjectType%3A+corporate+AND+mycoreid:[\"\"+TO+*]";
					param += "&wt=json&indent=true&rows=100";
					
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
								+ 'servlets/solr/select?&q=%2Bmods.title%3A*%QUERY*+%2Bcategory.top%3A%22mir_genres\%3Aseries%22+%2BobjectType%3A%22mods%22&version=4.5&rows=100&fl=mods.title%2Cid%2Cmods.identifier&wt=json',
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
				var query = this.query;
				var words = query.split(' ');
				for (i=0; i < words.length ;i++) {
					word = words[i];
					var re = new RegExp(word,"i");
				    obj = obj.replace(re, function (x) {return "<b>" + x + "</b>"});
				}
				return (obj);
 			},
 			matcher: function (item) {
                return -1;
            },
		});

	});

	

});



