Router.map ->
  @route 'loading',
    path: '/loading'
    template: 'loading'

  @route 'Signup',
    path: '/register'
    template: 'register'

  @route 'Render User',
    path: '/:publicURL'
    waitOn: ->
      # deal with null or non-existant userIds???
      Meteor.subscribe 'Tiles'
      Meteor.subscribe 'Users'#, {public_url: @params.publicURL}
    data: ->
      return unless @ready() is true  # Only do this stuff once the data is available:
      if Meteor.users.find().count() is 0
        @redirect '/loading'
      context =
        public_url: @params.publicURL

      # (1) Did the user specific a specific Tile link?
      if @params.hash
        context['show_tile_id'] = @params.hash

      # (2) Now lets construct a data object containing cat/tile info:
      categories = {}
      for tile in Tiles.find({}, {'sort': {'pos.category': 1, 'pos.tile': 1}}).fetch()
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
        colour = "hsl(#{hue}, 65%, 50%)"
        for tile in cat.tiles
          tile['colour'] = colour
        category_list.push
          title: title
          tiles: cat.tiles
          color: colour
        hue += delta_hue
      context['categories'] = category_list

      # (3) Pass that shit to the template engine!
      return context
    action: ->
      if @ready() is true
        @render 'allTiles'

Router.configure
  loadingTemplate: 'loading'
  layoutTemplate: 'appLayout'
