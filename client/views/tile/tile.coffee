#
#   Template.tile
#
Template.tileSmall.events
  'click .tile-content': (event, template) ->
    return if event.target.tagName is "A"
    Session.set "currentlyViewing", @tile._id
  'click a.tile-read-more': (event, template) ->
    Session.set "currentlyViewing", @tile._id
  ###
  'click a.tile-edit': ->
    Router.go "/edit/#{@tile._id}"
  ###
  'click a.tile-delete': ->
    Session.set "setToDelete", @tile._id
    $('#delete-tile-confirmation').openModal()
