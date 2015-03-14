#
#   Template.tile
#
Template.tile.events
  'click a.tile-read-more': (event, template) ->
    data = Template.currentData()
    tileViewModal data.tile
  'click a.tile-edit': ->
    data = Template.currentData()
    tileEditModal.open data.tile
  'click a.tile-delete': ->
    data = Template.currentData()
    Session.set "setToDelete", data.tile._id
    modal = $('#delete-tile-confirmation')
    modal.openModal()
