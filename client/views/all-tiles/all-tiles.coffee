#
#   Template.allTiles
#
Template.allTiles.created = ->
  @publicURL = FlowRouter.getParam 'publicURL'

  #
  # (1) Find the user whose publicURL this is:
  #
  user_q =
    "profile.public_url": @publicURL
  user_filter =
    fields:
      profile: 1
  user = Meteor.users.findOne( user_q, user_filter )
  if !user?
    # If there is no user with this URL, present the "Not Found" page:
    FlowLayout.render 'notFound'

  #
  # (2) Map Categories to Colours:
  #
  cat_q =
    owner: user._id
  cat_filter =
    sort:
      pos: 1
  _cats = Categories.find( cat_q, cat_filter ).fetch()
  delta_hue = 360/_cats.length
  hue = 0
  colours = {}
  for cat in _cats
    colour = "hsl(#{hue}, 65%, 50%)"
    colours[ cat.title ] = colour
    hue += delta_hue

  # (3) Did the user specify a specific Tile hash?
  #if @params.hash
  #  context[ 'show_tile_id' ] = @params.hash

  #
  # (4) Construct a category_list data object:
  #
  categories = {}
  tiles = {}
  _q =
    owner: user._id
  if !Session.get("search")?
    console.log "Retrieving ALL tiles..."
    _tiles = Tiles.find(_q, _sort)
  else
    if Session.get("search").length > 0
      console.log "Conducting search on #{Session.get("search")}"
      _tiles = Tiles.searchByKeyword
        selector: _q
        fields: ["title", "searchableContent", "category"]
        keywords: Session.get("search")
    else
      console.log "Retrieving ALL tiles..."
      _tiles = Tiles.find(_q, _sort)
  return unless _tiles?
  for tile in _tiles.fetch()
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




Template.allTiles.rendered = ->
  Session.set "tileSortableDisabled", true
  Session.set "categorySortableDisabled", true
  Session.set "currentlyEditing", null
  Session.set "search", null
  #$('.toast').remove()

  # Trigger search field on key down:
  $(document).on "keydown", (event) ->
    for tagName in ["INPUT", "TEXTAREA"]
      return if event.target.tagName is tagName
    $("#right-menu").sidebar 'hide'
    $("input#tile-search").focus()

  document.title = @data.renderedUser.profile.name # set the page title to be the user's name

  @data.categories = Session.get "categories"

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



    #toast "The URL you're looking for no longer exists!", 5000, "danger"


#
#   Template.categories
#
Template.categories.helpers
  'emptyTiles': ->
    if (cat for cat of Session.get("colours")).length is 0
      return true
    else
      return false
