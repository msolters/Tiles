#jsZip = Meteor.npmRequire 'jszip'
xmlBuilder = Meteor.npmRequire 'xmlbuilder'

Meteor.methods
  exportData: ->
    #
    # (1) Find user profile and all categories belonging.
    #
    userId = Meteor.userId()
    cat_q =
      owner: userId
    cat_proj =
      fields:
        _id: 0
        owner: 0
    tiles_proj =
      fields:
        _id: 0
        owner: 0
    _user = Meteor.user()
    _cats = Categories.find(cat_q, cat_proj).fetch()

    #
    # (3) Construct the User section of the backup Profile.
    #
    profile = xmlBuilder.create 'profile'
    user = profile.ele 'user'
    user.ele 'name', _user.profile.name
    #
    # (4) Construct an XML Category object for each Category
    #     belonging to the User.
    #
    categories = profile.ele 'categories'
    for _cat in _cats
      c = categories.ele 'category'
      #
      # (5) Get the Tiles belonging to this Category.
      #
      tiles_q =
        _id:
          $in: _cat.tiles
      delete _cat['tiles']
      _tiles = Tiles.find(tiles_q, tiles_proj).fetch()

      #
      # (6) Populate the XML node for each Category with
      #     Category data and also the Tiles belonging to it.
      #
      for k, v of _cat
        c.ele k, v

      #
      # mapToXML: A helper method that recursively generates
      #           appropriate XML tree nodes from complex JSON
      #           objects.
      #           For example, t0 and t1 are complex objects
      #           with a variable number of possible parameters.
      #
      mapToXML = (name, o, xml=null) ->
        if typeof o is "object"
          props = (k for k, v of o)
          if props.length > 0
            _xml = xml.ele name
            for k, v of o
              mapToXML k, v, _xml
            return
        xml.ele name, o

      tiles = c.ele 'tiles'
      for _tile in _tiles
        t = tiles.ele 'tile'
        for k, v of _tile
          mapToXML k, v, t

    #
    # (7) Create an XML string.
    #
    xmlString = profile.end
      pretty: true

  importData: (content) ->
    #
    # (1) Clear all old data:
    #
    Tiles.remove({owner: Meteor.userId()})
    Categories.remove({owner: Meteor.userId()})

    #
    # (2) Parse incoming XML data to JSON
    #
    results = xml2js.parseStringSync content,
      explicitArray: false
    console.dir results
    _profile = results.profile

    #
    # (3) Update user's name
    #
    _user = _profile.user
    user_q =
      _id: Meteor.userId()
    user_update =
      $set:
        "profile.name": _user.name
    Meteor.users.update user_q, user_update

    #
    # (4) Iterate over Categories:
    #
    if !_profile.categories.category.length?
      _profile.categories.category = [ _profile.categories.category ]
    for cat in _profile.categories.category
      if !cat.tiles.tile.length?
        cat.tiles.tile = [ cat.tiles.tile ]
      #
      # (5) Insert New Tiles.
      #
      tile_ids = []
      for t in cat.tiles.tile
        t.owner = Meteor.userId()
        # If there's timestamps, turn them from ints -> Date objects
        if t.t0?
          if t.t0.timestamp?
            t.t0.timestamp = new Date parseInt t.t0.timestamp
        if t.t1?
          if t.t1.timestamp?
            t.t1.timestamp = new Date parseInt t.t1.timestamp
        console.log "insert ", t
        tile_ids.push Tiles.insert t
      console.log tile_ids
      #
      # (6) Create Category Object
      #
      cat.tiles = tile_ids
      cat.owner = Meteor.userId()
      Categories.insert cat
    return {
      success: true
    }
