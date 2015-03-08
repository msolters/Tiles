Meteor.publish 'Tiles', ->
  return Tiles.find()
Meteor.publish 'Users', ->
  return Meteor.users.find()

Meteor.startup ->

Meteor.methods
  # Create a user (the only user) who can create/edit tiles
  # This is only used if the user wants to specify their own
  # e-mail and password (i.e. not Google, FB, etc.)
  createNewUser: (email, password, name) ->
    Accounts.createUser
      email: email
      password: password
      profile:
        name: name
  updateUser: (userId, _user) ->
    Meteor.users.update(
      {_id: userId}
      $set: _user
    )
  # Inserts or updates a tile specified by _id with the data in
  # the _tile object argument.
  saveTile: (_tile, _id=null) ->
    _updateAdd =
      $set: {}
    _updateRemove =
      $unset: {}

    if _tile.dates? #  If one or both dates are null, remove them from the DB
      if _tile.dates.dateOne is null
        _updateRemove['$unset']['dates.dateOne'] = ''
        delete _tile.dates.dateOne
      if _tile.dates.dateTwo is null
        _updateRemove['$unset']['dates.dateTwo'] = ''
        delete _tile.dates.dateTwo
      if (d for d,v of _tile.dates).length is 0
        delete _tile.dates
    _updateAdd['$set'] = _tile
    #console.log _updateAdd
    #console.log _updateRemove
    Tiles.upsert(
      {_id: _id}
      _updateAdd
      {multi: true}
    )
    Tiles.update(
      {_id: _id}
      _updateRemove
      {multi: true}
    )
  # Removes a tile specified by _id from the Tiles collection:
  deleteTile: (_id) ->
    Tiles.remove(_id: _id)
  # Renames all Tiles of category 'category' to '_category':
  saveCategory: (category, _category) ->
    console.log "#{category} -> #{_category}"
    Tiles.update(
      {category: category},
      {$set:
        category: _category},
      {multi: true}
    )
