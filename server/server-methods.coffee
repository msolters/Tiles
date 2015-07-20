###
#   Server-side methods:
###
Meteor.methods
  ###
  #   Given a currentUser from a template context, and the URL of
  #   the client's current route, determine if the currentUser is
  #   authorized to manipulate the page at that URL.
  ###
  verifyUser: (user, url) ->
    db_user = Meteor.users.findOne({"profile.public_url": url})
    if user? and db_user?
      if user._id is db_user._id
        return true
    return false

  ###
  #   Check that the provided URL is not in use by another user already.:
  ###
  verifyURL: (url) ->
    #
    # (1) Make sure the URL exists!
    #
    if url.length is 0
      return {
        success: false
        msg: "Please enter a URL."
      }
    #
    # (2) Test for slashes.
    #
    if RegExp(/[\\/]/).test url is true
      return {
        success: false
        msg: "Sorry, no slashes!"
      }
    #
    # (3) Test for URI encoding mismatches.
    #
    url_encoded = encodeURIComponent url
    if url isnt url_encoded
      return {
        success: false
        msg: "#{url} cannot used be as a URL.  (Avoid spaces, slashes, symbols or other weird characters.)"
      }
    #
    # (4) Test for banned URLs
    #
    bannedURLs = ['login', 'register', 'loading', 'setup']
    for bannedURL in bannedURLs
      if bannedURL is url
        return {
          success: false
          msg: "Sorry, you cannot use that as a personal URL."
        }
    #
    # (5) Make sure no other users have the URL already.
    #
    _user = Meteor.users.findOne(
      "profile.public_url": url
    )
    if _user
      if _user._id isnt Meteor.userId()
        return {
          success: false
          msg: "Sorry, that URL is already taken."
        }
    return {
      success: true
    }

  ###
  #   Create a user (the only user) who can create/edit tiles
  #   This is only used if the user wants to specify their own
  #   e-mail and password (i.e. not Google, FB, etc.)
  ###
  createNewUser: (email, password, name, url) ->
    userId = Accounts.createUser
      email: email
      password: password
      profile:
        name: name
        public_url: url

  ###
  #
  ###
  updateUser: (_user) ->
    console.log _user
    Meteor.users.update(
      {_id: Meteor.userId()}
      $set: _user
    )
    return true

  ###
  #   Upserts a tile specified by _id with the data in
  #   the _tile object argument.
  ###
  saveTile: (_tile) ->
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

    # (1)  insert/upsert/update Tile
    if !_tile._id?
      _tile.owner = Meteor.userId()
      _id = Tiles.insert(
        _tile
      )
    else
      _id = _tile._id
      delete _tile['_id']
      _q =
        _id: _id
        owner: Meteor.userId()
      _updateAdd['$set'] = _tile
      Tiles.upsert(
        _q,
        _updateAdd,
        {multi: true}
      )
      if (p for p of _updateRemove.$unset).length > 0
        Tiles.update(
          _q
          _updateRemove
          {multi: true}
        )
    if _tile.category?
      _q =
        owner: Meteor.userId()
        title: _tile.category
      _update =
        $addToSet:
          tiles: _id
      Categories.upsert(_q, _update) # assign tile to new category
      _q =
        owner: Meteor.userId()
        tiles: _id
        title:
          $ne: _tile.category
      _update =
        $pull:
          tiles: _id
      Categories.update(_q, _update) # remove tile from old category (if applicable)
      _cleanup =
        owner: Meteor.userId()
        tiles:
          $size: 0
      Categories.remove(_cleanup) # delete any categories containg 0 tiles



  ###
  #   Updates tile(s) meeting the _query criteria with the
  #   _update operations:
  ###
  updateTiles: (_query, _update) ->
    _query.owner = Meteor.userId() # only allow ops on Tiles belonging to the currently logged in user
    Tiles.update(
      _query
      $set:
        _update
      {multi: true}
    )

  ###
  #   Updates category(ies) meeting the _query criteria with the
  #   _update operations:
  ###
  updateCategories: (_query, _update) ->
    _query.owner = Meteor.userId() # only allow ops on Tiles belonging to the currently logged in user
    Categories.update(
      _query
      $set:
        _update
      {multi: true}
    )

  ###
  #   Removes a tile specified by _id from the Tiles collection:
  ###
  deleteTile: (_id) ->
    Tiles.remove(
      _id: _id
      owner: Meteor.userId()
    )
    _q =
      owner: Meteor.userId()
      tiles: _id
    _update =
      $pull:
        tiles: _id
    Categories.update(_q, _update) # remove tile from old category (if applicable)
    _cleanup =
      owner: Meteor.userId()
      tiles:
        $size: 0
    Categories.remove(_cleanup) # delete any categories containg 0 tiles
