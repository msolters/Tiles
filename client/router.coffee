Router.map ->
  @route 'Home',
    path: '/'
    action: ->
      if !Meteor.user()?
        if Meteor.loggingIn()
          @render "loading"
        else
          @render "register"
      else
        if Meteor.user().profile.public_url?
          @redirect "/#{Meteor.user().profile.public_url}"
        else
          @redirect "/setup"

  @route 'Register',
    path: '/register'
    template: 'register'

  @route 'Loading',
    path: '/loading'

  @route 'Setup',
    path: '/setup'
    template: 'establishURL'
    action: ->
      if !Meteor.user()?
        if Meteor.loggingIn()
          @render "loading"
        else
          @redirect "/"
      else
        @render 'establishURL'

  @route 'Render User',
    path: '/:publicURL'
    template: 'allTiles'
    waitOn: ->
      Meteor.subscribe 'Tiles'
      Meteor.subscribe 'Users'#, {public_url: @params.publicURL}
    data: ->
      return unless @ready() is true  # Only do this stuff once the data is available:
      user = Meteor.users.findOne({"profile.public_url": @params.publicURL})
      if !user?
        @render 'notFound' #this isn't a valid url; no page exists here.
        return

      if Meteor.user()?
        if !Meteor.user().profile.public_url?
          @redirect '/setup'
          return

      context =
        public_url: @params.publicURL

      # (1) Did the user specific a specific Tile link?
      if @params.hash
        context['show_tile_id'] = @params.hash

      # (2) Now lets construct a data object containing cat/tile info:
      categories = {}
      tiles = {}
      _q =
        owner: user._id
      if !Session.get("search")?
        console.log "Retrieving ALL tiles..."
        _tiles = Tiles.find(_q, _sort)
      else
        if Session.get("search").length > 0
          console.log "Conducting search on #{Session.get("search")}"
          _tiles = Tiles.searchByKeyword
            fields: ["title", "content"]
            keywords: Session.get("search")
        else
          console.log "Retrieving ALL tiles..."
          _tiles = Tiles.find(_q, _sort)
      for tile in _tiles.fetch()
        category = tile.category
        tiles[tile._id] = tile
        if !categories[category]?
          categories[category] =
            tile_ids: [ tile._id ]
        else
          categories[category].tile_ids.push tile._id
      category_list = []
      numCategories = (c for c of categories).length
      delta_hue = 360/numCategories
      hue = 0
      for title, cat of categories
        colour = "hsl(#{hue}, 65%, 50%)"
        for _id in cat.tile_ids
          tiles[_id].colour = colour
        category_list.push
          title: title
          tile_ids: cat.tile_ids
          color: colour
        hue += delta_hue

      #console.log 'Server delivers data:'
      #console.log category_list
      #console.log tiles
      Session.set "categories", category_list
      Session.set "tiles", tiles

      # (3) Pass that shit to the template engine!
      return context


#  Define defaults:
Router.configure
  loadingTemplate: 'loading'
  layoutTemplate: 'appLayout'
  notFoundTemplate: 'notFound'
Router.onBeforeAction 'loading'
