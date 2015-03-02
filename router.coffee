Router.map ->
  @route 'Home',
    path: '/'
    template: 'allTiles'
    waitOn: ->
      Meteor.subscribe 'Tiles'
      Meteor.subscribe 'Users'
    data: ->
      return unless @ready() is true
      context = {}
      if @params.hash
        context['show_tile_id'] = @params.hash

      categories = {}
      console.log "Creating Tile data object...."
      for tile in Tiles.find({}, {'sort': {'category': 1}}).fetch()
        if tile.category.length is 0
          category = "Uncategorized"
        else
          category = tile.category
        if !categories[category]?
          categories[category] =
            tiles: [ tile ]
        else
          categories[category].tiles.push tile

      category_list = []
      numCategories = (c for c of categories).length
      delta_hue = 360/numCategories
      hue = 0
      for title, cat of categories
        category_list.push
          title: title
          tiles: cat.tiles
          color: "hsl(#{hue}, 65%, 50%)"
        hue += delta_hue
      context['categories'] = category_list
      return context
