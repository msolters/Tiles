Meteor.publish 'Tiles', ->
  return Tiles.find()
Meteor.publish 'Users', ->
  return Meteor.users.find()

Meteor.startup ->

Meteor.methods
  # Inserts or updates a tile specified by _id with the data in
  # the _tile object argument.
  saveTile: (_tile, _id=null) ->
    Tiles.upsert(
      {_id: _id}
      $set: _tile
    )
  # Removes a tile specified by _id from the Tiles collection:
  deleteTile: (_id) ->
    Tiles.remove(_id: _id)
  # Renames all instances of category with new category, _category
  saveCategory: (category, _category) ->
    console.log "#{category} -> #{_category}"
    category = '' if category is 'Uncategorized'
    Tiles.update(
      {category: category},
      {$set:
        category: _category},
      {multi: true}
    )
  # Renames all instances of category with an empty string
  deleteCategory: (category) ->
    Tiles.update(
      {category: category},
      {$set:
          category: ''},
      {multi: true}
    )
  # getNumberUsers is used to disable the registration button if a
  # User has already been created!
  getNumberUsers: ->
    if Meteor.users.find().count() > 0
      return true
    else
      return false
