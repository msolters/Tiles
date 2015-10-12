###
#     Template.confirmDeleteTile
###
Template.confirmDeleteTile.events
  "click button[data-delete-tile]": (event, template) ->
    Meteor.call "deleteTile", @tile._id, (err, resp) ->
      Materialize.modalize.close()
      if err?
        toast "Error removing tile: #{err}", 7500, "danger"
      else
        toast "Tile successfully deleted!", 4000, "success"
