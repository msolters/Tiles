###
#   Template.editTile
###
Template.editTile.created = ->
  #
  # (1) Tile edit is not available to 2 subsets of users:
  #       1. Users not logged in at all
  #       2. Users who don't own the tile referenced in the URL
  #     For these users, we render a 'notFound' template.
  #     We handle case 1 in the following autorun block:
  @autorun =>
    ifLoggedOut ->
      FlowLayout.render 'notFound'

  #
  # (2) Construct a Reactive Map object to store
  #     information about the tile being edited:
  #
  @tileMap = new ReactiveMap()

  #
  # (3) If this is a pre-existing tile, pre-populate the
  #     Reactive Map above with the data from the
  #     database record for it.
  #
  @autorun =>
    tile_id = FlowRouter.getParam 'tile_id'
    if tile_id isnt 'new'
      _tile = Tiles.findOne(
        _id: tile_id
      )
      if Meteor.userId() is _tile.owner
        # The current user does own this tile; let us proceed.
        @tileMap.set _tile
      else
        # Here we handle case 2 from step (1) above, users viewing a tile
        # edit dialog but who do not own the tile:
        FlowLayout.render 'notFound'


Template.editTile.helpers
  tile: ->
    Template.instance().tileMap.all()
  tileMap: ->
    Template.instance().tileMap
  minimumTile: ->
    _tile = Template.instance().tileMap.all()
    if nonEmptyString(_tile.title) is true or nonEmptyString(_tile.content) is true or nonEmptyString(_tile.preview) is true or _tile.dates?
      return true
    return false

Template.editTile.events
  'click a[data-cancel]': ->
    FlowRouter.go "/#{Meteor.user().profile.public_url}"
  'click a[data-confirm]': (event, template) ->
    _tile = template.tileMap.all()
    #_tile.category = $("input#tile-category").focusout().val() # focusout is necessary to force autocomplete (if active) to finish
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
  ###
  #   Event callbacks to update the Reactive Map object
  #   storing the data about the tile we are currently editing.
  ###
  'input input#tile-title': (event, template) ->
    #
    # (1) Update the tileMap with the title the user just
    #     entered from the text input.
    #
    template.data.tileMap.set
      title: event.target.value
  'input input#tile-category, keydown input#tile-category': (event, template) ->
    #
    # (1) Determine the colour corresponding to the category
    #     the user just entered from the text input.
    #
    _category = event.target.value
    #color=Session.get("colours")[_category]
    if color?
      _color = color
    else
      _color = "#000000"
    #
    # (2) Update the tileMap with the category and colour
    #     based on the data above.
    #
    template.data.tileMap.set
      category: _category
      color: _color
  'input input#date-one': (event, template) ->
    #
    # (1) Create a _dates object representing the dates
    #     the user has entered, if any.
    #
    tileMap = template.data.tileMap
    _dates = tileMap.get 'dates'
    _dates = {} if !_dates?
    dateVal = event.target.value
    if dateVal.length > 0
      _dates.dateOne = new Date dateVal
    else
      if _tile.dates.dateTwo?
        delete _dates['dateOne']
      else
        _dates = undefined
    #
    # (2) Update the tileMap with this new _dates data.
    #     If _dates is undefined, we delete the key 'dates'
    #     from the tileMap.  Otherwise, we set it to its new
    #     value.
    #
    if _dates?
      tileMap.set
        dates: _dates
    else
      tileMap.delete 'dates'
  'input input#date-two': (event, template) ->
    #
    # (1) Create a _dates object representing the dates
    #     the user has entered, if any.
    #
    tileMap = template.data.tileMap
    _dates = tileMap.get 'dates'
    _dates = {} if !_dates?
    dateVal = event.target.value
    if dateVal.length > 0
      _dates.dateTwo = new Date dateVal
    else
      if _tile.dates.dateOne?
        delete _dates['dateTwo']
      else
        _dates = undefined
    #
    # (2) Update the tileMap with this new _dates data.
    #     If _dates is undefined, we delete the key 'dates'
    #     from the tileMap.  Otherwise, we set it to its new
    #     value.
    #
    if _dates?
      tileMap.set
        dates: _dates
    else
      tileMap.delete 'dates'
  'input textarea#tile-preview': (event, template) ->
    #
    # (1) Update the tileMap with the tile preview content
    #     the user just entered from the text input.
    #
    template.data.tileMap.set
      preview: event.target.value
  'input textarea#tile-content': (event, template) ->
    #
    # (1) Update the tileMap with the tile content
    #     the user just entered from the text input.
    #
    template.data.tileMap.set
      content: event.target.value
  ###
  #   Event callbacks to handle autocomplete field for
  #   Tile categories.
  ###
  'focus .twitter-typeahead input': (event, template) ->
    input_field = $(event.currentTarget).parent().parent()
    input_field.find("i").addClass "active"
    input_field.find("label").addClass "active"
  'focusout .twitter-typeahead input': (event, template) ->
    if $(event.currentTarget).val().length is 0
      input_field = $(event.currentTarget).parent().parent()
      input_field.find("i").removeClass "active"
      input_field.find("label").removeClass "active"
