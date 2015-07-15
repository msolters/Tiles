###
#   Template.tileSmall
###
Template.tileSmall.created = ->
  console.log @

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
    MaterializeModal.confirm
      bodyTemplate: 'tileBigEdit'
      fixedFooter: true
      submitLabel: '<i class="mdi-action-save left"></i>Save'
      cancelLabel: 'Cancel'
      tile: template.data.tile
      callback: (yesNo) =>
        if yesNo
          #
          # (1) First we construct & validate a _tile object.
          #
          
          #
          # (?) Save the Tile into the database.
          #
          Meteor.call "saveTile", _tile, _id, (error, response) ->
            if error
              toast "Error saving tile: #{error}", 6000, "danger"
            else
              toast "Tile saved successfully!", 4000, "success"
              FlowRouter.go "/#{Meteor.user().profile.public_url}"
