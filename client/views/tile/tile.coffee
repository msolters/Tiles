###
#   Template.tileSmall
###
Template.tileSmall.events
  'click a[data-delete-tile]': ->
    MaterializeModal.confirm
      title: 'Delete Tile?'
      message: 'Are you sure you want to permanently erase this Tile?  You will not be able to recover or restore any of its data by proceeding.'
      submitLabel: '<i class="mdi-action-delete left"></i>Delete'
      cancelLabel: 'Cancel'
      callback: (yesNo) =>
        if yesNo
          Meteor.call "deleteTile", @tile._id, (err, resp) ->
            if err?
              toast "Error removing tile: #{err}", 7500, "danger"
            else
              toast "Tile successfully deleted!", 4000, "success"
  'click a[data-edit-tile]': (event, template) ->
    MaterializeModal.bare
      bodyTemplate: 'tileBigEdit'
      tile: template.data.tile
