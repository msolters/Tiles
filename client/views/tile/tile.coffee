###
#   Template.tileSmall
###
Template.tileSmall.events
  'click a[data-delete-tile]': ->
    Materialize.modalize.display
      title: 'Delete Tile?'
      template: 'confirmDeleteTile'
      tile: @tile
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
    if tile.t0?
      if tile.t0.precision?
        _t0 = moment(tile.t0.timestamp).format precisionToFormatMap[tile.t0.precision]
    if tile.t1?
      if tile.t1.precision?
        _t1 = moment(tile.t1.timestamp).format precisionToFormatMap[tile.t1.precision]
    if _t0? and _t1?
      return "#{_t0} &ndash; #{_t1}"
    else if _t0?
      return _t0
    else
      return _t1
