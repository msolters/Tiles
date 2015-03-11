Meteor.publish 'Tiles', (slug={}) ->
  return Tiles.find(slug)
Meteor.publish 'Users', (slug={}) ->
  return Meteor.users.find(slug)

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
    query =
      $or: []
    _.each Accounts.oauth.serviceNames(), (name) ->
        q = {}
        q["services.#{name}.email"] = email;
        query.$or.push(q);
        q = {};
        q["services.#{name}.emailAddress"] = email
        query.$or.push q
    query.$or.push
      'emails.address': email
    if Meteor.users.find(query)?
      throw new Meteor.Error 500, 'Could not create new user.', 'E-mail already taken.'
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
    return {success: true}
  updateUser: (_user) ->
    Meteor.users.update(
      {_id: Meteor.userId()}
      $set: _user
    )
  # Upserts a tile specified by _id with the data in
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
  #   Updates tile(s) meeting the _query criteria with the
  #   _update operations:
  updateTiles: (_query, _update) ->
    _query.owner = Meteor.userId() # only allow ops on Tiles belonging to the currently logged in user
    Tiles.update(
      _query
      $set:
        _update
      {multi: true}
    )
  # Removes a tile specified by _id from the Tiles collection:
  deleteTile: (_id) ->
    Tiles.remove(
      _id: _id
      owner: Meteor.userId()
    )

# First remove any services that may have been auto/already configured:
ServiceConfiguration.configurations.remove
  service:
    $in: ["facebook", "twitter", "google"]

ServiceConfiguration.configurations.insert
  service: "google"
  clientId: "204767897565-0htfv8rfc4njfhnkqbm3c3dsr4f3o9ra.apps.googleusercontent.com"
  secret: "_s3YqyBq4yDW2aIYvVvb0VaZ"
ServiceConfiguration.configurations.insert
  service: "facebook",
  appId: "363206583870762",
  secret: "5303f40d3f93963a3636035a2eb1a36b"
