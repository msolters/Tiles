###
#     Icon Directory (For Development Only)
###
FlowRouter.route '/icons',
  name: 'MDI Icon Listing'
  action: ->
    FlowLayout.render 'icons'


###
#     FlowRouter mechanism for mapping URLs -> Templates
###

###
#     Home
###
FlowRouter.route '/',
  name: 'Home'
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
      controls: null

###
#     Login
###
FlowRouter.route '/login',
  name: 'Login'
  subscriptions: (params, qParams) ->
  action: (params) ->
    FlowLayout.render 'app',
      main: 'login'


###
#     Setup
###
FlowRouter.route '/setup',
  name: 'Setup'
  subscriptions: (params, qParams) ->
    #@register "UserData", Meteor.subscribe "UserData"
  action: (params) ->
    FlowLayout.render 'app',
      main: 'establishURL'

###
#     Edit Tile
###
FlowRouter.route '/edit/:tile_id',
  name: 'Edit Tile'
  subscriptions: (params, qParams) ->
    @register 'Tiles', Meteor.subscribe 'Tiles',
      _id: params.tile_id
    @register 'Users', Meteor.subscribe 'Users',
      _id: Meteor.userId()
  action: (params) ->
    FlowLayout.render 'app',
      main: 'editTile'

###
#     Render User
###
FlowRouter.route '/:publicURL',
  name: 'Render User'
  subscriptions: (params, qParams) ->
    @register 'Users', Meteor.subscribe 'Users',
      "profile.public_url": params.publicURL
  action: (params) ->
    FlowLayout.render 'app',
      main: 'allTiles'

###
#     Render User, Tile Overlay
###
FlowRouter.route '/:publicURL/:tileID',
  name: 'Render User'
  subscriptions: (params, qParams) ->
    @register 'Users', Meteor.subscribe 'Users',
      "profile.public_url": params.publicURL
  action: (params) ->
    FlowLayout.render 'app',
      main: 'allTiles'

###
#     Triggers
###
###
clearTooltips = ->
  btns = document.querySelectorAll( ".btn-floating:hover" )
  $btns = $ btns
  $btns.mouseleave()
  $btns.mouseenter()
FlowRouter.triggers.enter [ clearTooltips ]
###
