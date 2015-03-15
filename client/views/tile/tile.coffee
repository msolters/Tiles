#
#   Template.tile
#
Template.tile.events
  'click .tile-content': ->
    Session.set "currentlyViewing", @tile._id
  'click a.tile-read-more': (event, template) ->
    Session.set "currentlyViewing", @tile._id
  'click a.tile-edit': ->
    data = Template.currentData()
    tileEditModal.open data.tile
  'click a.tile-delete': ->
    Session.set "setToDelete", @tile._id
    $('#delete-tile-confirmation').openModal()
