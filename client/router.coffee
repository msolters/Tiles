routerBeforeHooks =
  loginRequired: ->
    if !Meteor.user()?
      if Meteor.loggingIn() is true
        @render 'loading'
      else
        toast "Yeahhh, if you could just...login.....that would be greeaaat.", 7500, "danger"
        @render 'loginScreen'
    else
      @next()

Router.map ->
  @route 'Home',
    path: '/'
    action: ->
      if !Meteor.user()?
        if Meteor.loggingIn()
          @render "loading"
        else
          @render "home"
      else
        if Meteor.user().profile.public_url?
          @redirect "/#{Meteor.user().profile.public_url}"
        else
          Router.go "/setup"

  @route 'Register',
    path: '/register'
    template: 'register'

  @route 'Loading',
    path: '/loading'

  @route 'Setup',
    path: '/setup'
    template: 'establishURL'
    yieldTemplates:
      'rightMenu':
        to: 'rightMenu'
      'setupNavbar':
        to: 'navbar'

  @route 'Edit Tile',
    path: '/edit/:tile_id'
    template: 'editTile'
    yieldTemplates:
      'editTileMenu':
        to: 'rightMenu'
      'editTileNavbar':
        to: 'navbar'
    waitOn: ->
      Meteor.subscribe 'Tiles'
      Meteor.subscribe 'Users'#, {public_url: @params.publicURL}
    data: ->
      return unless @ready() is true  # Only do this stuff once the data is available:
      if @params.tile_id is "new"
        _tile = {}
      else
        _tile = Tiles.findOne(
          owner: Meteor.userId()
          _id: @params.tile_id
        )
      Session.set "currentlyEditing", _tile


  @route 'Render User',
    path: '/:publicURL'
    template: 'allTiles'
    yieldTemplates:
      'tileViewModal':
        to: 'modals'
      'manageTilesMenu':
        to: 'rightMenu'
      'renderUserNavbar':
        to: 'navbar'
    waitOn: ->
      Meteor.subscribe 'Tiles'
      Meteor.subscribe 'Categories'
      Meteor.subscribe 'Users'#, {public_url: @params.publicURL}
    data: ->
      return unless @ready() is true  # Only do this stuff once the data is available:
      user = Meteor.users.findOne({"profile.public_url": @params.publicURL}, {fields: {profile: 1}})
      if !user?
        @render 'notFound' #this isn't a valid url; no page exists here.
        return

      if Meteor.user()?
        if !Meteor.user().profile.public_url?
          @redirect '/setup'
          return

      #   Define persistent colours based on all categories:
      cat_q =
        owner: user._id
      cat_sort =
        sort:
          pos: 1
      _cats = Categories.find(cat_q, cat_sort).fetch()
      delta_hue = 360/_cats.length
      hue = 0
      colours = {}
      for cat in _cats
        colour = "hsl(#{hue}, 65%, 50%)"
        colours[cat.title] = colour
        hue += delta_hue

      context =
        public_url: @params.publicURL
        renderedUser: user

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
            selector: _q
            fields: ["title", "searchableContent", "category"]
            keywords: Session.get("search")
        else
          console.log "Retrieving ALL tiles..."
          _tiles = Tiles.find(_q, _sort)
      return unless _tiles?
      for tile in _tiles.fetch()
        category = tile.category
        tile.color = colours[category]
        tiles[tile._id] = tile
        if !categories[category]?
          categories[category] =
            tile_ids: [ tile._id ]
        else
          categories[category].tile_ids.push tile._id

      category_list = []
      for ordered_title, colour of colours
        if categories[ordered_title]?
          category_list.push
            title: ordered_title
            tile_ids: categories[ordered_title].tile_ids
            color: colour

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
Router.onBeforeAction routerBeforeHooks.loginRequired,
  only: ['Edit Tile', 'Setup']
