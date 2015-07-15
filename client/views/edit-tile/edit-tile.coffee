###
#   Template.tileEditForm
###
Template.tileEditForm.created = ->
  @autorun =>
    ifLoggedOut ->
      FlowLayout.render 'notFound'
    if Meteor.userId() isnt Template.currentData().owner
      # If users are somehow viewing a tile
      # edit dialog but who do not own the tile:
      FlowLayout.render 'notFound'

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
