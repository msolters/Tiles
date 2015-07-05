###
#   Template.allTilesControls
###
Template.allTilesControls.created = ->
  @autorun =>
    ifLoggedIn ->
      Meteor.setTimeout ->
        Session.set "menuOpen", true
      , 15
    ifLoggedOut ->
      Session.set "menuOpen", false

Template.allTilesControls.helpers
  open: ->
    return Session.get "menuOpen"

Template.allTilesControls.events
  'click a[data-login]': ->
    MaterializeModal.custom
      title: 'Login'
      bodyTemplate: 'loginForm'
      modal: true
    $('#user-email').focus()
  'click a[data-logout]': ->
    Meteor.logout()
    $('.toast').remove()
    toast "Take us out of orbit, Mr. Sulu.  Warp 1.", 3000, "success"
  'click a[data-toggle-menu]': (event, template) ->
    _currentState = Session.get 'menuOpen'
    Session.set 'menuOpen', !_currentState
