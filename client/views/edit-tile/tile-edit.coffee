#
#   Template.tileEditModal
#
Template.tileEditModal.rendered = ->
  Meteor.typeahead.inject() # configure category autocomplete
  modal = $ "#tile-edit-modal"
  #instantiateTileEditModal @
  @autorun ->
    _id = Session.get "currentlyEditing"
    if !_id?
      console.log "close that shit"
      #Router.go "#{window.location.pathname}#"
      modal.closeModal()
    else
      console.log "open that shit"
      modal.find('.progress').show()
      modal.openModal
        ready: =>
          console.log @
          $('textarea#tile-content').keydown() # configure content textarea size
          modal.find('.progress').hide()
          #Router.go "#{window.location.pathname}##{_id}"
        complete: ->
          console.log "done"
          Session.set "currentlyEditing", null
          #Router.go "#{window.location.pathname}"

Template.tileEditModal.helpers
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

Template.tileEditModal.events
  'focus .twitter-typeahead input': (event, template) ->
    input_field = $(event.currentTarget).parent().parent()
    input_field.find("i").addClass "active"
    input_field.find("label").addClass "active"
  'focusout .twitter-typeahead input': (event, template) ->
    if $(event.currentTarget).val().length is 0
      input_field = $(event.currentTarget).parent().parent()
      input_field.find("i").removeClass "active"
      input_field.find("label").removeClass "active"
  'click button#cancel-tile-edit': ->
    Session.set "currentlyEditing", null
  'click #save-tile-edit': (event, template) ->
    tileEditModal.showLoading()
    _tile = tileEditModal.getTile() # get user's changes
    if _tile.errors?  #Something critical like a title or category is missing!  Abort save.
      for e in _tile.errors
        toast e, 6500, "danger"
      return false
    else # Save that shit!
      if !_tile._id?  # tile is new!
        pos = {}
        k = 0
        for cat, i in Session.get "categories"
          if cat.title is _tile.category
            _tile.pos =
              category: i
              tile: cat.tile_ids.length
            break
          else
            k++
        if !_tile.pos? # no matching category!  add tile in last category, first tile position.
          _tile.pos =
            category: k
            tile: 0
      _id = _tile._id
      delete _tile['_id']
      Meteor.call "saveTile", _tile, _id, (error, response) ->
        if error
          toast "Error saving tile: #{error}", 6000, "danger"
          tileEditModal.hideLoading()
        else
          toast "Tile saved successfully!", 4000, "success"
          tileEditModal.close()
    return false
