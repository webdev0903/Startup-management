$(document).ready ->

  # Function to check if user has joined 3 or more groups.
  # If yes than let him continue
  continueStep2 = ->
    groupsJoined = $('.userListFollow.btn-success:visible').length
    if groupsJoined >= 3
      $('#skip-step-2').hide()
      $('#continue-step-2').show()
    else
      $('#skip-step-2').show()
      $('#continue-step-2').hide()


  # for Step 2 upon user sign-up
  if $('#skip-step-2').length > 0
    continueStep2()

    $('body').unbind('groupJoined').bind 'groupJoined', (event) ->
      continueStep2()
    $('body').unbind('groupLeaved').bind 'groupLeaved', (event) ->
      continueStep2()


