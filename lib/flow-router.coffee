###
#     FlowRouter mechanism for mapping URLs -> Templates
###

###
#     Home
###
FlowRouter.route '/',
  name: 'Home'
  subscriptions: (params, qParams) ->
    #@register "UserData", Meteor.subscribe "UserData"
  action: (params) ->
    FlowRouter.go "/login"


###
#     Register
###
FlowRouter.route '/register',
  name: 'Register'
  subscriptions: (params, qParams) ->
  action: (params) ->
    FlowLayout.render 'app',
      main: 'register'


###
#     Login
###
FlowRouter.route '/login',
  name: 'Register'
  subscriptions: (params, qParams) ->
  action: (params) ->
    FlowLayout.render 'app',
      main: 'loginForm'


###
#     Setup
###
FlowRouter.route '/setup',
  name: 'Setup'
  subscriptions: (params, qParams) ->
    #@register "UserData", Meteor.subscribe "UserData"
  action: (params) ->
    FlowLayout.render 'internalLayout',
      main: 'establishURL'

###
#     Edit Tile
###
FlowRouter.route '/edit/:tile_id',
  name: 'Edit Tile'
  subscriptions: (params, qParams) ->
  action: (params) ->
    FlowLayout.render 'internalLayout',
      main: 'editTile'


###
#     Render User
###
FlowRouter.route '/:publicURL',
  name: 'Render User'
  subscriptions: (params, qParams) ->
    @register 'Tiles', Meteor.subscribe 'Tiles'
    @register 'Categories', Meteor.subscribe 'Categories'
    @register 'Users', Meteor.subscribe 'Users'
  action: (params) ->
    FlowLayout.render 'app',
      rightMenu: 'manageTilesMenu'
      navbar: 'renderUserNavbar'
      #main: 'allTiles'
