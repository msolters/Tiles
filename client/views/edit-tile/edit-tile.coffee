#
#   Template.tileEdit
#
Template.editTile.helpers
  'tile': ->
    Session.get "currentlyEditing"
  'minimumTile': ->
    _tile = Session.get "currentlyEditing"
    if nonEmptyString(_tile.title) is true or nonEmptyString(_tile.content) is true or nonEmptyString(_tile.preview) is true or _tile.dates?
      return true
    return false

#
#   Template.tileEditModal
#
Template.tileEditForm.rendered = ->
  Meteor.typeahead.inject() # configure category autocomplete

Template.tileEditForm.helpers
  'categories': ->
    cats = Tiles.find({owner: Meteor.userId()}).fetch().map (it) ->
      return it.category
    return _.uniq cats
  'getEditTile': ->
    _id = Session.get "currentlyEditing"
    return {} if _id is "new"
    tiles = Session.get "tiles"
    if tiles?
      if _id?
        if tiles[_id]?
          return tiles[_id]

Template.tileEditForm.events
  'input input#tile-title': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.title = event.target.value
    Session.set "currentlyEditing", _tile
  'input input#tile-category': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.category = event.target.value
    Session.set "currentlyEditing", _tile
  'input input#date-one': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.dates = {} if !_tile.dates?
    dateVal = event.target.value
    if dateVal.length > 0
      _tile.dates.dateOne = new Date dateVal
    else
      delete _tile.dates['dateOne']
    Session.set "currentlyEditing", _tile
  'input input#date-two': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.dates = {} if !_tile.dates?
    dateVal = event.target.value
    if dateVal.length > 0
      _tile.dates.dateTwo = new Date dateVal
    else
      delete _tile.dates['dateTwo']
    Session.set "currentlyEditing", _tile
  'input textarea#tile-preview': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.preview = event.target.value
    Session.set "currentlyEditing", _tile
  'input textarea#tile-content': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.content = event.target.value
    Session.set "currentlyEditing", _tile

  'focus .twitter-typeahead input': (event, template) ->
    input_field = $(event.currentTarget).parent().parent()
    input_field.find("i").addClass "active"
    input_field.find("label").addClass "active"
  'focusout .twitter-typeahead input': (event, template) ->
    if $(event.currentTarget).val().length is 0
      input_field = $(event.currentTarget).parent().parent()
      input_field.find("i").removeClass "active"
      input_field.find("label").removeClass "active"
