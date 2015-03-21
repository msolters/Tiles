###
#     Template helpers, events, et cetera for the client.
###


#
#   Template.allTiles
#
Template.allTiles.rendered = ->
  Session.set "tileSortableDisabled", true
  Session.set "categorySortableDisabled", true
  Session.set "currentlyEditing", null
  Session.set "search", null
  $('.toast').remove()
  $(document).on "keydown", (event) ->
    for tagName in ["INPUT", "TEXTAREA"]
      return if event.target.tagName is tagName
    $("#right-menu").sidebar 'hide'
    $("input#tile-search").focus()
  data = @data
  data.categories = Session.get "categories"
  if data.categories?
    if data.categories.length is 0
      if !Meteor.user()?
        toast "Looks like you need to add some content.<br>Sign in using the menu in the top right!", 15000, "info"
        $('#right-menu').sidebar 'show'
      else
        @autorun ->
          if Meteor.user()?
            if Meteor.user().profile.public_url is data.public_url
              toast "Now that you're logged in, you can create new tiles from the right-side menu!", 15000, "success"
              $('#right-menu').sidebar 'show'

    @autorun =>
      renderTrigger.depend()
      data=Template.currentData()
      _inner = $("#tile-container-inner")[0]
      Blaze.remove Blaze.getView _inner if _inner?
      if Session.get("tiles")?
        if (t for t,tile of Session.get("tiles")).length > 0
          Blaze.renderWithData Template.categories, data, @find("#tile-container")
        else
          if Session.get("search")?
            if Session.get("search").length > 0
              Blaze.renderWithData Template.noResults, data, @find("#tile-container")

    if data.show_tile_id? # if the user passed a hash, see if its a Tile and open it in the modal!
    #  console.log "Setting currentlyViewing: #{data.show_tile_id}"
      Session.set "currentlyViewing", data.show_tile_id
      return
    #toast "The URL you're looking for no longer exists!", 5000, "danger"

#
#     Template.deleteTileConfirmation
#
Template.deleteTileConfirmation.events
  'click button[data-delete-tile]': ->
    Meteor.call "deleteTile", Session.get("setToDelete"), (err, resp) ->
      if err?
        toast "Error removing tile: #{err}", 7500, "danger"
      else
        toast "Tile successfully deleted!", 4000, "success"
