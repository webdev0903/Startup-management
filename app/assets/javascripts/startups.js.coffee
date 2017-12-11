$(document).ready ->

  $('#search_for_startups').on 'click', ->
    Turbolinks.visit '/startups/markets/' + $('#startup_markets_search').val() if $('#startup_markets_search').val() isnt ''