#   Template helpers, events, et cetera for the client.

#
#   Template.allTiles
#
Template.allTiles.rendered = ->
  data = Template.currentData()
  if data.show_tile_id? # if the user passed a hash, see if its a Tile and open it in the modal!
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
  'click a.tile-read-more': ->
    tileViewModal @tile
  'click a.tile-edit': ->
    openTileEditModal @tile


#
#   Template.categoryEditList
#
Template.categoryEditList.events


#
#   Template.categoryEdit
#
Template.categoryEdit.events
  'click .collapsible-header': (event, template) ->
    return unless event.target.className is "collapsible-header row"
    content = $(event.currentTarget.parentNode).find('.collapsible-body')
    content.slideToggle('fast') if content?
  'input': (event, template) ->
    $(template.find('.save-category')).show()
  'submit form.category-form': (event, template) ->
    _title = template.find('#category-title').value
    Meteor.call "saveCategory", template.data.title, _title, (error, response) ->
      if error
        toast "Error: #{error}", 10000
      else
        $(template.find('.save-category')).hide()
    return false


#
#   Template.tileEdit:
#
Template.tileEdit.events
  'click button.edit-tile': ->
    openTileEditModal @
  'click button.delete-tile': ->
    Meteor.call "deleteTile", @_id

#
#   Template.tileEditModal
#
Template.tileEditModal.events
  'click #save-tile-edit': (event, template) ->
  #'submit form.tile-form': (event, template) ->
    #save_button = event.currentTarget
    progress_bar = template.find '.progress'
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
    _id = Session.get "currentlyEditing"
    $(progress_bar).show()
    Meteor.call "saveTile", new_tile, _id, (error, response) ->
      closeTileEditModal()
    return false


#
#   Template.navbar
#
Template.navbar.events
  'click a.add-new-tile': ->
    openTileEditModal()

Template.navbar.rendered = ->
  $('.button-collapse').sideNav
    menuWidth: 300
    edge: 'right'
    closeOnClick: true

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
