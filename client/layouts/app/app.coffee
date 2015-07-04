###
#   Template.app
###
Template.app.events
  'click a[data-login]': ->
    $('#login-modal').openModal()
    $('#user-email').focus()
  'click a[data-logout]': ->
    Meteor.logout()
    $('.toast').remove()
    toast "Take us out of orbit, Mr. Sulu.  Warp 1.", 3000, "success"
