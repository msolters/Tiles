@resetTiles = new Deps.Dependency
@reloadTiles = new Deps.Dependency

@editTile = ->
  MaterializeModal.display
    bodyTemplate: 'tileBigEdit'
    fullscreen: true
    fixedFooter: true
    tile: @tile

###
#   Runs callback method cb if the user is not logged in.
###
@ifLoggedOut = (cb=null) ->
  if !Meteor.user()?
    if !Meteor.loggingIn()
      cb()

###
#   Runs callback method cb is the user is logged in.
###
@ifLoggedIn = (cb=null) ->
  if Meteor.user()?
    cb()
