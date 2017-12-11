// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.remotipart
//= require_tree ./lib
//= require turbolinks
//= require jquery.turbolinks
//= require turbolinks.redirect
//= require nprogress-turbolinks
//= require nprogress-ajax
//= require underscore
//= require underscore_open_fix
//= require contact
//= require groups
//= require keywords
//= require pages
//= require startups
//= require mixpanel.tracker

$(document).ready(function(){
    /*Group Autocomlete*/
	$('#group_search_autocomplete').typeahead({
	  minLength: 2,
	  highlight: true,
	},
	{
		displayKey: 'title',
	  source: function(query,cb){
	  	$.ajax({
        dataType: 'json',
        url: '/groups/autocomplete.json?qs=' + query,
        success: function(data) {        		
			    cb(data);
        }
      });    
    },
    templates: {
    	suggestion: function(data){
    		return '<a href="/groups/' + data.url + '"> <img width="32" height="32" src="' + data.photo + '"> ' + data.title + ' </a>';
    	},
    	empty: function(data){
    		return '<a class="typeahead_footer" href="/groups?qs='+ data.query +'">Search for <strong>"'+ data.query + '</strong>"</a>'
    	},
    	footer: function(data){
    		if(data.isEmpty)
    			return;
    		return '<hr><a class="typeahead_footer" href="/groups?qs='+ data.query +'">Search for <strong>"'+ data.query + '</strong>"</a>'
    	}
    }
	});
    /*Startup Autocomplete*/
    $('#startup_search_autocomplete').typeahead({
      minLength: 2,
      highlight: true,
    },
    {
      displayKey: 'title',
      source: function(query,cb){
        $.ajax({
        dataType: 'json',
        url: '/startups/autocomplete.json?qs=' + query,
        success: function(data) {               
          cb(data);
        }
      });    
    },
    templates: {
        suggestion: function(data){
            return '<a href="/startups/' + data.url + '"> <img width="32" height="32" src="' + data.photo + '"> ' + data.title + ' </a>';
        }
    }
    });

   
    /*Startup Country Autocomplete*/
    $('#startup_country_title').typeahead({
      minLength: 2,
      highlight: true,
    },
    {
        displayKey: 'title',
        source: function(query,cb){
        $.ajax({
        dataType: 'json',
        data: {
            term: query
        },
        url: $('#startup_country_title').data('autocomplete-source') ,
        success: function(data) {    
            var ret = [];
            Object.keys(data).forEach(function(key){
                ret.push({
                    title: key,
                    count: data[key]
                });
            })      
                cb(ret);
        }
      });    
    },
    templates: {
        suggestion: function(data){
            return data.title + ' <span>(' + data.count + ')</span>';
        }
    }
    });

    /*Startup CIty autocomplete*/
    $('#startup_city_name').typeahead({
      minLength: 2,
      highlight: true,
    },
    {
        displayKey: 'title',
        source: function(query,cb){
        $.ajax({
        dataType: 'json',
        data: {
            term: query
        },
        url: $('#startup_city_name').data('autocomplete-source') ,
        success: function(data) {    
            var ret = [];
            Object.keys(data).forEach(function(key){
                ret.push({
                    title: key,
                    count: data[key]
                });
            })      
                cb(ret);
        }
      });    
    },
    templates: {
        suggestion: function(data){
            return data.title;
        }
    }
    });


    /*Profile City Autocomplete*/
    if($("#user_profile_attributes_city").length){
      
      var autocomplete = new google.maps.places.Autocomplete($("#user_profile_attributes_city")[0],{
        types: ['(cities)']
      });      
      google.maps.event.addListener(autocomplete, 'place_changed', function() {
        var place = autocomplete.getPlace();
        var city;
        if(place.address_components){
          place.address_components.forEach(function(component) {
            if (component.types.indexOf('locality') > -1) {
              city = component.long_name;
            }
          });
          if (!city) {
            city = place.address_components[0].long_name;
          }
        }        
        var formatted_address_array = place.formatted_address.split(",");
        return $("#user_profile_attributes_city").val(city || place.name || formatted_address_array[0]);
      });
    }


    var select2_for_skills = function(element) {
      if ($('#' + element).length > 0) {
        return $('#' + element)
        .select2({
          multiple: true,
          tags: true,
          templateResult: function(data) {
            if(data.loading)
              return data;

            //data.element = data.element || document.createElement('option');

            var users_count = $(data.element).data('usersCount') || 0;
            
            return $('<div class="keyword_field">' + data.text + '<div class="keyword_field_inside">' + users_count + ' users</div></div>');
          },  
          matcher: function (params, data, matched) {
            if(matched.length === 10)
              return null;

            if ($.trim(params.term) === '') {
              return data;
            }
            if (data.text.toLowerCase().indexOf(params.term.toLowerCase()) > -1) {
              return data;
            }
            return null;
          }
        });
      }
    };
    var select2_for_markets = function(element) {
      if ($('#' + element).length > 0) {
        return $('#' + element).select2({
          multiple: true,
          tags: true,
          templateResult: function(data) {
            if(data.loading)
              return data;

            var startups_count = $(data.element).data('startupsCount') || 0;
            var followers_count = $(data.element).data('followersCount') || 0;

            return $('<div class="keyword_field">' + data.text + '<div class="keyword_field_inside">' + startups_count + ' startups, ' + followers_count + ' followers</div></div>');
          },  
          matcher: function (params, data, matched) {
            if(matched.length === 10)
              return null;

            if ($.trim(params.term) === '') {
              return data;
            }
            if (data.text.toLowerCase().indexOf(params.term.toLowerCase()) > -1) {
              return data;
            }
            return null;
          }
        });
      }
    };

    var select2_for_cofounders = function(element) {
      if ($('#' + element).length > 0) {
        return $('#' + element).select2({
          multiple: true,
          tags: true,
          templateResult: function(data) {
            if(data.loading)
              return data;
            //data.element = data.element || document.createElement('option');

            var url = $(data.element).data('url') || '';            
            return $('<div class="friend_field"><div class="friend_field_inside"><div class="friend_field_photo"><img src="' + url +  '"></div><div class="friend_field_title">' + data.text +  '</div></div></div>');
          },  
          matcher: function (params, data) {            
            if ($.trim(params.term) === '') {
              return data;
            }
            if (data.text.toLowerCase().indexOf(params.term.toLowerCase()) > -1) {
              return data;
            }
            return null;
          },
          createTag: function(params) {
            return undefined;
          }
        });
      }
    };
    
    var select2_tagging = function(element) {
      if ($('#' + element).length > 0) {
        return $('#' + element).select2({
          multiple: true,
          tags: true,
        });
      }
    };

    select2_tagging('user_profile_attributes_website')
    select2_for_skills('user_profile_attributes_skills');
    select2_for_markets('user_profile_attributes_markets_interested_in');
    select2_for_markets('startup_markets_search');
    select2_for_markets('startup_markets')
    select2_for_cofounders('startup_cofounder_ids')
    
    $('.groupstartupsList .panel-title').each(function(i, el){
    	var data = $(el).find('.panel-title-1 a').ellipsis({
    		lines: 2,
    		ellipClass: 'ellip',
    		responsive: true  
    	}).data('ellipsis');
    	
    	var lines = data && data.currLine && data.currLine == 1 ? 3 : 2;
    	$(el).find('.panel-title-2').ellipsis({
    		lines: lines,
    		ellipClass: 'ellip',
    		responsive: true  
    	});
    });

    $('.startupList .panel-title').each(function(i, el){
      var data = $(el).find('.panel-title-1 a').ellipsis({
        lines: 2,
        ellipClass: 'ellip',
        responsive: true  
      }).data('ellipsis');
      
      var lines = data && data.currLine && data.currLine == 1 ? 2 : 1;
      $(el).find('.panel-title-2').ellipsis({
        lines: lines,
        ellipClass: 'ellip',
        responsive: true  
      });
    });

    $('.starterList .panel-title').each(function(i, el){
      var data = $(el).find('.panel-title-1 a').ellipsis({
        lines: 2,
        ellipClass: 'ellip',
        responsive: true  
      }).data('ellipsis');
      
      var lines = data && data.currLine && data.currLine == 1 ? 2 : 1;
      $(el).find('.panel-title-2').ellipsis({
        lines: lines,
        ellipClass: 'ellip',
        responsive: true  
      });
    });
});
