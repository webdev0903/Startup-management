$(document).ready ->

  $(".makeHigherTextarea").autosize()

  $('#postsList').on 'click', '.show-more', (event) ->
    event.preventDefault()
    $(this).parent().hide()
    $(this).parent().next().show()
    false

  $('#postsList').on 'click', '.show-less', (event) ->
    event.preventDefault()
    $(this).parent().hide()
    $(this).parent().prev().show()
    false

  $('#postsList').on 'click', '.addCommentLink', (event) ->
    event.preventDefault()
    class_selector = '.comment-on-' + $(this).data('postId')
    $(class_selector).show()
    false

  $('body').on 'click', '.give-a-gem', (event) ->
    event.preventDefault()
    $(this).next().submit()
    false

  $('#more-posts-link').on 'click', ->
    $('#more-posts-laoder').show()
    $(this).hide()

  csrfToken = $("meta[name='csrf-token']").attr("content")
  stopPing = false

  pingStatus = parseInt($.cookie('starterPadPing') | '0')

  if csrfToken and (pingStatus < 1)
    setInterval ->
      if !stopPing
        $.cookie 'starterPadPing', pingStatus + 1
        $.ajax
          type: 'PUT'
          url: "/users/ping.json"
          data:
            authenticity_token: csrfToken
          error: (data) ->
            stopPing = true
    , 3000 * 60

  $(window).unload ->
    $.cookie 'starterPadPing', pingStatus - 1 if pingStatus > 0


$ ->  $("#starter_country_title").autocomplete
        source: $("#starter_country_title").data('autocomplete-source')

$ ->  $("#starter_city_name").autocomplete
  source: $("#starter_city_name").data('autocomplete-source')
