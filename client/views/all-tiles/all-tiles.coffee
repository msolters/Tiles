###
#   Template.allTiles
###
Template.allTiles.created = ->

  #
  # (1) Create a ReactiveVar containing the current URL:
  #
  @publicURL = new ReactiveVar 0
  @tileID = new ReactiveVar 0
  @autorun =>
    @publicURL.set FlowRouter.getParam 'publicURL'
    @tileID.set FlowRouter.getParam 'tileID'

  #
  # (1) Find the user whose page we're currently viewing:
  #
  @user = new ReactiveVar 0
  @autorun =>
    user_q =
      "profile.public_url": @publicURL.get()
    user = Meteor.users.findOne( user_q )
    if !user?
      # If there is no user with this URL, present the "Not Found" page:
      #FlowLayout.render 'notFound'
    else
      @user.set user
      ownership_q =
        owner: user._id
      Meteor.subscribe 'Tiles', ownership_q
      Meteor.subscribe 'Categories', ownership_q

  #
  # (2) Create Reactive Categories data structure:
  #
  @categories = new ReactiveVar 0
  @autorun =>
    cat_q =
      owner: @user.get()._id
    cat_filter =
      sort:
        pos: 1
    @categories.set Categories.find( cat_q, cat_filter ).fetch()

  #
  # (3) Reactively map Categories to Colours:
  #
  @colours = new ReactiveVar 0
  @autorun =>
    _cats = @categories.get()
    delta_hue = 360/_cats.length
    hue = 0
    colours = {}
    for cat in _cats
      colour = "hsl(#{hue}, 65%, 50%)"
      colours[ cat.title ] = colour
      hue += delta_hue
    @colours.set colours

  # (3) Did the user specify a specific Tile hash?
  #if @params.hash
  #  context[ 'show_tile_id' ] = @params.hash

  #
  # (4) Create Reactive Tiles data structure:
  #
  @search = new ReactiveVar 0 # search query
  @tiles = new ReactiveVar 0  # array of Tiles matching query and URL
  @autorun =>
    _search = @search.get()
    tiles_q =
      owner: @user.get()._id
    if !_search?
      console.log "Retrieving all tiles..."
      _tiles = Tiles.find( tiles_q, _sort )
    else
      if _search.length > 0
        console.log "Conducting search on #{_search}"
        _tiles = Tiles.searchByKeyword
          selector: tiles_q
          fields: [ "title", "searchableContent", "category" ]
          keywords: _search
      else
        console.log "Retrieving all tiles..."
        _tiles = Tiles.find( tiles_q, _sort )
    if _tiles?
      @tiles.set _tiles.fetch()
    else
      @tiles.set []

  #
  # (5) Create a Reactive sortedTiles data structure:
  #
  @sortedCategories = new ReactiveVar 0
  @sortedTiles = new ReactiveVar 0
  @autorun =>
    reloadTiles.depend()
    categories = {}
    tiles = {}
    _tiles = @tiles.get()
    colours = @colours.get()
    return unless _tiles?
    for tile in _tiles
      category = tile.category
      tile.color = colours[category]
      tiles[tile._id] = tile
      if !categories[category]?
        categories[category] =
          tile_ids: [ tile._id ]
      else
        categories[category].tile_ids.push tile._id

    category_list = []
    for ordered_title, colour of colours
      if categories[ordered_title]?
        category_list.push
          title: ordered_title
          tile_ids: categories[ordered_title].tile_ids
          color: colour
    @sortedCategories.set category_list
    @sortedTiles.set tiles

  #
  # (6) Set a Reactive listener that will redraw the
  #     categorise and tiles if the global Deps object
  #     resetTiles is ever .changed()
  #
  @autorun =>
    resetTiles.depend()
    $('.tile-content')
      .addClass "pointer"
      .removeClass "grabbable"
    $('.tile a')
      .removeClass "grabbable"
    $('.tile')
      .removeClass "grabbable"
    @sortedCategories.set null
    @sortedTiles.set null
    reloadTiles.changed()

Template.allTiles.rendered = ->
  # Trigger search field on key down:
  ###
  $(document).on "keydown", (event) ->
    for tagName in ["INPUT", "TEXTAREA"]
      return if event.target.tagName is tagName
    $("input#tile-search").focus()
  ###

  #
  # Make the #tile-container 100% height, minus
  # whatever the current height of the navbar is.
  #
  resizeTileContainer = ->
    $("#tile-container").css
      "height": "calc(100% - #{$('nav').height()}px)"
  $(window).resize resizeTileContainer
  resizeTileContainer()

  #
  # (?) Reactively update the page's title
  #
  @autorun =>
    if @user.get()
      _name = @user.get().profile.name
    else
      _name = "TilesJS"
    document.title = _name

  #
  # If @tileID.get() has a value, open a modal showing
  # that tile.
  #
  @autorun =>
    _tileID = @tileID.get()
    if _tileID?
      _tile = Tiles.findOne( {_id: _tileID} )
      if _tile?
        _tile.color = @colours.get()[ _tile.category ]
        Materialize.modalize.display
          template: 'tileBig'
          fixedFooter: true
          fullScreen: true
          tile: _tile
          callback: (yesNo, rtn, event) =>
            FlowRouter.go "/#{@publicURL.get()}"


Template.allTiles.helpers
  sortedCategories: ->
    Template.instance().sortedCategories.get()
  sortedTiles: ->
    Template.instance().sortedTiles.get()
  underTwoTiles: ->
    if Template.instance().tiles.get().length < 2
      return true
    else
      return false
  underTwoCategories: ->
    if Template.instance().categories.get().length < 2
      return true
    else
      return false
  search: ->
    Template.instance().search.get()
  searchVar: ->
    # This is not the value of the ReactiveVar `search`,
    # it is a reference to the variable itself.
    Template.instance().search
  user: ->
    Template.instance().user.get()

Template.allTiles.events
  'click a[data-add-tile]': ->
    editTile.apply {tile: {}}
  'click a[data-settings]': ->
    Materialize.modalize.display
      template: 'settings'
      bottomSheet: true
  'mousewheel #tile-scroller': (event, template) ->
    event.currentTarget.scrollLeft += event.originalEvent.deltaY

###
#   Template.categories
###
Template.categories.helpers
  emptyTiles: ->
    if (t for t of Template.currentData().sortedTiles).length is 0
      return true
    else
      return false

###
#   Template.category
###
Template.category.helpers
  tiles: ->
    return (Template.currentData().tiles[ tile_id ] for tile_id in Template.currentData().category.tile_ids)
