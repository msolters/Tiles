#
#   Template.allTiles
#
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

  document.title = @data.renderedUser.profile.name

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
