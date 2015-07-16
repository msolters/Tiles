jsZip = Meteor.npmRequire 'jszip'
xmlBuilder = Meteor.npmRequire 'xmlbuilder'

Meteor.methods
  exportData: ->
    #
    # (1) Create ZIP file destination.
    #
    zip = new jsZip()

    #
    # (2) Find user profile and all categories belonging.
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
        c.ele k, JSON.stringify v
      tiles = c.ele 'tiles'
      for _tile in _tiles
        t = tiles.ele 'tile'
        for k, v of _tile
          t.ele k, JSON.stringify v

    #
    # (7) Create an XML string.
    #
    xmlString = profile.end
      pretty: true

    #
    # (8) Zip it up!
    #
    zip.file 'profile.xml', xmlString
    zip.generate
      type: "base64"

  importData: (content) ->
    #parser = new xml2js.Parser()
    results = xml2js.parseStringSync content
    console.log results
    return JSON.stringify results
