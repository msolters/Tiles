#
#   Template.tile
#
Template.tile.events
  'click a.tile-read-more': (event, template) ->
    tileViewModal @tile._id
  'click a.tile-edit': ->
    data = Template.currentData()
    tileEditModal.open data.tile
  'click a.tile-delete': ->
    Session.set "setToDelete", @tile._id
    $('#delete-tile-confirmation').openModal()
