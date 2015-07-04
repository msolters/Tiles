###
#   Template.allTiles
###
Template.allTiles.created = ->
  #
  # (1) Create a ReactiveVar containing the current URL:
  #
  @publicURL = new ReactiveVar 0
  @autorun =>
    @publicURL.set FlowRouter.getParam 'publicURL'

  #
  # (1) Find the user whose page we're currently viewing:
  #
  @user = new ReactiveVar 0
  @autorun =>
    user_q =
      "profile.public_url": @publicURL.get()
    user_filter =
      fields:
        profile: 1
    user = Meteor.users.findOne( user_q, user_filter )
    if !user?
      # If there is no user with this URL, present the "Not Found" page:
      FlowLayout.render 'notFound'
    else
      @user.set user

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
    @tiles.set _tiles

  #
  # (5) Create a Reactive sortedTiles data structure:
  #
  @sortedCategories = new ReactiveVar 0
  @sortedTiles = new ReactiveVar 0
  @autorun =>
    categories = {}
    tiles = {}
    _tiles = @tiles.get()
    colours = @colours.get()
    return unless _tiles?
    for tile in _tiles.fetch()
      category = tile.category
      tile.color = @colours[category]
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


Template.allTiles.rendered = ->
  ###
  Session.set "tileSortableDisabled", true
  Session.set "categorySortableDisabled", true
  Session.set "currentlyEditing", null
  Session.set "search", null
  ###
  #$('.toast').remove()

  # Trigger search field on key down:
  $(document).on "keydown", (event) ->
    for tagName in ["INPUT", "TEXTAREA"]
      return if event.target.tagName is tagName
    $("#right-menu").sidebar 'hide'
    $("input#tile-search").focus()

  document.title = @user.get().profile.name # set the page title to be the user's name
  ###
  if @data.show_tile_id? # if the user passed a hash, see if its a Tile and open it in the modal!
    console.log "Setting currentlyViewing: #{data.show_tile_id}"
    Session.set "currentlyViewing", @data.show_tile_id

  @autorun =>
    renderTrigger.depend()
    data=Template.currentData()
    _inner = $("#tile-container-inner")[0]
    Blaze.remove Blaze.getView _inner if _inner?
    if Session.get("tiles")?
      if Session.get("search")?
        if Session.get("search").length > 0
          if (t for t,tile of Session.get("tiles")).length is 0
            Blaze.renderWithData Template.noResults, data, @find("#tile-container")
            return
      Blaze.renderWithData Template.categories, data, @find("#tile-container")
  ###

    #toast "The URL you're looking for no longer exists!", 5000, "danger"


Template.allTiles.helpers
  sortedCategories: ->
    Template.instance().sortedCategories.get()
  sortedTiles: ->
    Template.instance().sortedTiles.get()
  searchVar: ->
    # This is not the value of the ReactiveVar `search`,
    # it is a reference to the variable itself.
    Template.instance().search


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


###
#   Template.allTilesControls
###
Template.allTilesControls.events
  'click a[data-login]': ->
    $('#login-modal').openModal()
    $('#user-email').focus()
  'click a[data-logout]': ->
    Meteor.logout()
    $('.toast').remove()
    toast "Take us out of orbit, Mr. Sulu.  Warp 1.", 3000, "success"
