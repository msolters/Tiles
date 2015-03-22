#   Template helpers for ALL Templates.

###
#   Returns the user profile name of the page currently being
#   viewed.  Note that it does not depend on if the current
#   visitor is a user or not.
###
Template.registerHelper 'profileName', ->
  url = Router.current().params.publicURL
  return false if !url? or url is 'setup'
  db_user = Meteor.users.findOne({"profile.public_url": url})
  name = db_user.profile.name if db_user?
  return name if name?
  return false

###
#   Simple returns true if the tile object has at least one
#   date associated with it.
###
Template.registerHelper 'hasDates', (tile) ->
  if tile?
    if tile.dates?
      if (d for d of tile.dates).length > 0
        return true
  return false

###
#   Depending on if the dates argument object has none, one
#   or two children, renders an appropriate date or date range.
###
Template.registerHelper 'formatTileDates', (dates) ->
  if dates.dateOne? and dates.dateTwo?
    return "#{moment.utc(dates.dateOne).format('MMMM Do, YYYY')} &ndash; #{moment.utc(dates.dateTwo).format('MMMM Do, YYYY')}"
  else if dates.dateOne?
    return "#{moment.utc(dates.dateOne).format('MMMM Do, YYYY')}"
  else
    return "#{moment.utc(dates.dateTwo).format('MMMM Do, YYYY')}"

###
#   Taking a Date object or string representing one, return a string acceptable
#   as an input to an input[type=date].
###
Template.registerHelper 'formatInputDate', (date) ->
  return null if !date?
  moment(date).format('YYYY-MM-D')

###
#   If the input value is non-empty, returns the string 'active.'
#   The 'active' class is used by inputs to do things like move
#   input labels out of the way of the input content, etc.
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
#   This process takes the input text and returns another string
#   which undergoes a set of transformations which are used to
#   pre-format the Tile content (i.e., replace input newlines \n with
#   HTML newlines <br/>).
###
Template.registerHelper 'textToHTML', (text) ->
  text.replace(/(\r\n\r\n|\n\n|\r\r)/gm,"<br/>") if text?

###
#   Simply returns the tile object that is currently being modified in the
#   template editTile.
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
  return true if _id is "new"
  tiles = Session.get "tiles"
  if tiles?
    if _id?
      console.log "retrieving tile #{_id}..."
      if tiles[_id]?
        return tiles[_id]
      else
        toast "Sorry, looks like that Tile doesn't exist!", 3500, "danger" if hash_request is true
        Session.set "currentlyViewing", null
  #else
  #  $("#tile-view-modal").closeModal()
  console.log "No tile found." if _id?
  return false

Template.registerHelper 'searchQuery', ->
  Session.get 'search'
