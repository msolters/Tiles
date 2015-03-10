Meteor.publish 'Tiles', (slug={}) ->
  return Tiles.find(slug)
Meteor.publish 'Users', (slug={}) ->
  #console.log slug
  users = Meteor.users.find(slug)
  #console.log users.fetch()
  return users

Meteor.startup ->

Meteor.methods
  # Given a currentUser from a template context, and the URL of
  # the client's current route, determine if the currentUser is
  # authorized to manipulate the page at that URL.
  verifyUser: (user, url) ->
    db_user = Meteor.users.findOne({public_url: url})
    if user? and db_user?
      if user._id is db_user._id
        return true
    return false
  # Check that the provided URL is not in use by another user already.:
  verifyURL: (url) ->
    if Meteor.users.find({public_url: url}).count() is 0
      return true
    else
      return false
  # Create a user (the only user) who can create/edit tiles
  # This is only used if the user wants to specify their own
  # e-mail and password (i.e. not Google, FB, etc.)
  createNewUser: (email, password, name, url) ->
    userId = Accounts.createUser
      email: email
      password: password
      profile:
        name: name
    Meteor.users.update(
      {_id: userId}
      $set:
        public_url: url
    )
  updateUser: (_user) ->
    Meteor.users.update(
      {_id: Meteor.userId()}
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
        
    if !_id?
      _tile.owner = Meteor.userId()
      Tiles.insert(
        _tile
      )
    else
      _q =
        _id: _id
        owner: Meteor.userId()
      _updateAdd['$set'] = _tile
      console.log _updateAdd
      #console.log _updateRemove
      #console.log '\n'
      Tiles.upsert(
        _q,
        _updateAdd,
        {multi: true}
      )
      Tiles.update(
        _q
        _updateRemove
        {multi: true}
      )
  # Removes a tile specified by _id from the Tiles collection:
  deleteTile: (_id) ->
    Tiles.remove(
      _id: _id
      owner: Meteor.userId()
    )
