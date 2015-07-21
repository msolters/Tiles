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
    editTile.apply @


###
#   Template.tileDates
###
Template.tileDates.helpers
  hasDates: ->
    tile = Template.currentData().tile
    return true if tile.t0.precision? or tile.t1.precision?
    return false

  formatTileDates: ->
    precisionToFormatMap =
      years: 'YYYY'
      months: 'MMMM, YYYY'
      days: 'MMMM Do, YYYY'
    tile = Template.currentData().tile
    if tile.t0.precision?
      _t0 = moment(tile.t0.timestamp).format precisionToFormatMap[tile.t0.precision]
    if tile.t1.precision?
      _t1 = moment(tile.t1.timestamp).format precisionToFormatMap[tile.t1.precision]
    if _t0? and _t1?
      return "#{_t0} &ndash; #{_t1}"
    else if _t0?
      return _t0
    else
      return _t1
