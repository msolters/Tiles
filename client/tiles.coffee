#   Template helpers, events, et cetera for the client.

#
#   Template.allTiles
#
Template.allTiles.rendered = ->
  data = Template.currentData()
  if data.show_tile_id?
    for category in data.categories
      for tile in category.tiles
        if tile._id is data.show_tile_id
          tileViewModal tile
          break
      break

#
#   Template.category:
#
Template.category.rendered = ->


#
#   Template.tile
#
Template.tile.events
  'click a.tile-read-more': (event, template) ->
    tileViewModal @tile


#
#   Template.categoryEditList
#
Template.categoryEditList.events


#
#   Template.categoryEdit
#
Template.categoryEdit.events
  'click .collapsible-header': (event, template) ->
    console.log event.target
    # ^^^ if this is an input, dont expand!!!
    content = $(event.currentTarget.parentNode).find('.collapsible-body')
    content.slideToggle('fast') if content?
  'input': (event, template) ->
    $(template.find('.save-category')).show()
  'submit form.category-form': (event, template) ->
    _title = template.find('#category-title').value
    Meteor.call "saveCategory", template.data.title, _title
    return false


#
#   Template.tileEdit:
#
Template.tileEdit.helpers
  # This helper is used to hide/show delete button which
  # is unnecessary for the "new tile" card.
  isNotNew: ->
    if @tile? # this is an actual tile!
      return true
    else  # this is just the stock blank "new tile" object
      return false

Template.tileEdit.events
  'click': ->
    $('#tile-edit-modal').openModal()
  'click button.delete-tile': ->
    Meteor.call "deleteTile", @_id

#
#   Template.tileEditModal
#
Template.tileEditModal.rendered = ->
  $('#tile-edit-modal').leanModal
    dismissible: true # Modal can be dismissed by clicking outside of the modal
    opacity: 0.5   # Opacity of modal background
    in_duration: 300  #Transition in duration
    out_duration: 200   #Transition out duration
    ready: ->
      alert 'Ready'
    complete: ->
      alert 'Closed'

###   old tileEdit
Template.tileEdit.events
  'submit form.tile-form': (event, template) ->
    title = template.find '.tile-title'
    category = template.find '.tile-category'
    content = template.find '.tile-content'

    # Next let's validate that shit!
    if title.value.length is 0
      toast "Please enter a valid Title for this tile!", 6000
      return false
    if category.value.length is 0
      toast "Please enter a valid Category for this tile!", 6000
      return false

    # Create a new Tile object to upsert to the DB!
    new_tile =
      title: title.value
      content: content.value
      category: category.value

    # Save that shit!
    Meteor.call "saveTile", new_tile, @._id
    if !@._id? #  This tile is a "new tile" -- let's clear it!
      title.value = ""
      category.value = ""
      content.value = ""
    return false
  'input': (event, template) ->
    $(template.find('.save-tile')).slideDown()
  'click button.delete-tile': ->
    Meteor.call "deleteTile", @tile._id
###
