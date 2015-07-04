###
#   Template.editTile
###
Template.editTile.helpers
  'tile': ->
    Session.get "currentlyEditing"
  'minimumTile': ->
    _tile = Session.get "currentlyEditing"
    if nonEmptyString(_tile.title) is true or nonEmptyString(_tile.content) is true or nonEmptyString(_tile.preview) is true or _tile.dates?
      return true
    return false

Template.editTile.events
  'click a[data-cancel]': ->
    FlowRouter.go "/#{Meteor.user().profile.public_url}"
  'click a[data-confirm]': ->
    _tile = Session.get "currentlyEditing"
    _tile.category = $("input#tile-category").focusout().val()
    _errors = []
    if !nonEmptyString _tile.title
      _errors.push "Please enter a valid title for this Tile!"
    if !nonEmptyString _tile.category
      _errors.push "Please enter a valid category for this Tile!"
    if _errors.length > 0
      #@hideLoading()
      for error in _errors
        toast error, 4500, "danger"
      return
    else
      # Set _id (this depends on if it's a new or pre-existing tile)
      if _tile._id?
        _id = _tile._id
        delete _tile['_id']
      else
        _id = null

      # Convert preview and body content from HTML -> Text, for keyword searching:
      $("body").append("<div id='render-html'>#{_tile.content} #{_tile.preview}</div>")
      searchableContent = $("#render-html").text()
      $("#render-html").remove()

      _tile.searchableContent = searchableContent
      Meteor.call "saveTile", _tile, _id, (error, response) ->
        if error
          toast "Error saving tile: #{error}", 6000, "danger"
        else
          toast "Tile saved successfully!", 4000, "success"
          FlowRouter.go "/#{Meteor.user().profile.public_url}"



###
#   Template.tileEditForm
###
Template.tileEditForm.rendered = ->
  Meteor.typeahead.inject() # configure category autocomplete
  $("textarea").keydown()

Template.tileEditForm.helpers
  'categories': ->
    cats = Categories.find({owner: Meteor.userId()}).fetch().map (it) ->
      return it.title
    return cats

Template.tileEditForm.events
  'input input#tile-title': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.title = event.target.value
    Session.set "currentlyEditing", _tile
  'input input#tile-category': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.category = event.target.value
    color=Session.get("colours")[_tile.category]
    if color?
      _tile.color = color
    else
      _tile.color = "#000000"
    Session.set "currentlyEditing", _tile
  'keydown input#tile-category': (event, template) ->
    color=Session.get("colours")[event.target.value]
    _tile = Session.get "currentlyEditing"
    if color?
      _tile.color = color
    else
      _tile.color = "#000000"
    Session.set "currentlyEditing", _tile
  'input input#date-one': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.dates = {} if !_tile.dates?
    dateVal = event.target.value
    if dateVal.length > 0
      _tile.dates.dateOne = new Date dateVal
    else
      if _tile.dates.dateTwo?
        delete _tile.dates['dateOne']
      else
      delete _tile['dates']
    Session.set "currentlyEditing", _tile
  'input input#date-two': (event, template) ->
    _tile = Session.get "currentlyEditing"
    _tile.dates = {} if !_tile.dates?
    dateVal = event.target.value
    if dateVal.length > 0
      _tile.dates.dateTwo = new Date dateVal
    else
      if !_tile.dates.dateOne?
        delete _tile.dates['dateTwo']
      else
        delete _tile['dates']
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
