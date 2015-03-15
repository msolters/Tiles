Meteor.startup ->
  if !Meteor.user()
    $(document).on "keydown", (event) ->
      $("input#tile-search").focus()

###
#     Template helpers, events, et cetera for the client.
###

###
#
###
Template.registerHelper 'profileName', ->
  url = Router.current().params.publicURL
  return false if !url? or url is 'setup'
  db_user = Meteor.users.findOne({"profile.public_url": url})
  name = db_user.profile.name if db_user?
  if name?
    return name
  return false

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
  if !_id?
    _id = Session.get "currentlyViewing"
    hash_request = true
  console.log "retrieving tile #{_id}..."
  tiles = Session.get "tiles"
  if tiles?
    if _id?
      if tiles[_id]?
        return tiles[_id]
      else
        toast "Sorry, looks like that Tile doesn't exist!", 3500, "danger" if hash_request is true
        Session.set "currentlyViewing", null
  else
    $("#tile-view-modal").closeModal()
  console.log "No tile found."
  return false

Template.registerHelper 'searchQuery', ->
  Session.get 'search'

#
#   Template.allTiles
#
Template.allTiles.rendered = ->
  Session.set "tileSortableDisabled", true
  Session.set "categorySortableDisabled", true
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
      renderTrigger.depend()
      data=Template.currentData()
      _inner = $("#tile-container-inner")[0]
      Blaze.remove Blaze.getView _inner if _inner?
      if Session.get("tiles")?
        if (t for t,tile of Session.get("tiles")).length > 0
          Blaze.renderWithData Template.categories, data, @find("#tile-container")
        else
          if Session.get("search")?
            if Session.get("search").length > 0
              Blaze.renderWithData Template.noResults, data, @find("#tile-container")

    if data.show_tile_id? # if the user passed a hash, see if its a Tile and open it in the modal!
      console.log "Setting currentlyViewing: #{data.show_tile_id}"
      Session.set "currentlyViewing", data.show_tile_id
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
