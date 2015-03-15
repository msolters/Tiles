###
#     Template helpers, events, et cetera for the client.
###

###
#
###
Template.registerHelper 'profileName', ->
  url = Router.current().params.publicURL
  db_user = Meteor.users.findOne({"profile.public_url": url})
  name = db_user.profile.name if db_user?
  return name if name?

###
#
###
Template.registerHelper 'hasDates', (tile) ->
  if tile?
    if tile.dates?
      if (d for d of tile.dates).length > 0
        return true
  return false

###
#
###
Template.registerHelper 'formatTileDates', (dates) ->
  if dates.dateOne? and dates.dateTwo?
    return "#{moment(dates.dateOne).format('MMMM, YYYY')} &ndash; #{moment(dates.dateTwo).format('MMMM, YYYY')}"
  else if dates.dateOne?
    return "#{moment(dates.dateOne).format('MMMM, YYYY')}"
  else
    return "#{moment(dates.dateTwo).format('MMMM, YYYY')}"

###
#
###
Template.registerHelper 'activeOrNot', (value) ->
  if value?
    switch typeof value
      when "string"
        if value.length > 0
          return "active"
      when "number"
        return "active"

###
#
###
Template.registerHelper 'textToHTML', (text) ->
  text.replace(/(\r\n\r\n|\n\n|\r\r)/gm,"<br/><br/>") if text?

###
#
###
Template.registerHelper 'currentlyEditing', ->
  _tile = Session.get("currentlyEditing")
  if _tile?
    return _tile
  else
    return null

###
#
###
Template.registerHelper 'currentlyViewing', ->
  return Session.get "currentlyViewing"

###
#
###
Template.registerHelper 'verify', (user) ->
  url = Router.current().params.publicURL
  if Meteor.user()?
    db_url = Meteor.user().profile.public_url
    if db_url?
      if url is db_url
        return true
  return false

###
#   Returns category-tile tree object from session storage
###
Template.registerHelper 'categories', ->
  return Session.get "categories" or []

###
#   With no argument, returns the "currently viewing" tile.
#   Otherwise, returns the tile with that _id.
###
Template.registerHelper 'getTile', (_id=null) ->
  _id = Session.get "currentlyViewing" if !_id?
  console.log "retrieving tile #{_id}..."
  tiles = Session.get "tiles"
  if tiles?
    if tiles[_id]?
      console.log tiles[_id]
      return tiles[_id]
  console.log "No tile found."
  return false


#
#   Template.allTiles
#
Template.allTiles.rendered = ->
  $('.toast').remove()
  data = @data
  data.categories = Session.get "categories"
  if data.categories?
    if data.categories.length is 0
      if !Meteor.user()?
        toast "Looks like you need to add some content.<br>Sign in using the menu in the top right!", 15000, "info"
        $('#right-menu').sidebar 'show'
      else
        @autorun ->
          if Meteor.user()?
            if Meteor.user().profile.public_url is data.public_url
              toast "Now that you're logged in, you can create new tiles from the right-side menu!", 15000, "success"
              $('#right-menu').sidebar 'show'

    @autorun =>
      data=Template.currentData()
      _inner = $("#tile-container-inner")[0]
      Blaze.remove Blaze.getView _inner if _inner?
      Blaze.renderWithData Template.categories, data, @find("#tile-container")

    if data.show_tile_id? # if the user passed a hash, see if its a Tile and open it in the modal!
      tileViewModal data.show_tile_id
      return
    #toast "The URL you're looking for no longer exists!", 5000, "danger"


#
#     Template.deleteTileConfirmation
#
Template.deleteTileConfirmation.events
  'click button[data-delete-tile]': ->
    Meteor.call "deleteTile", Session.get("setToDelete"), (err, resp) ->
      if err?
        toast "Error removing tile: #{err}", 7500, "danger"
      else
        toast "Tile successfully deleted!", 4000, "success"
