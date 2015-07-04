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
    @register 'Tiles', Meteor.subscribe 'Tiles'
    @register 'Users', Meteor.subscribe 'Users'
  action: (params) ->
    FlowLayout.render 'app',
      main: 'editTile'

###
#     Show Icons (Development Only)
###
FlowRouter.route '/icons',
  name: 'MDI Icon Listing'
  action: ->
    FlowLayout.render 'icons'

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
      main: 'allTiles'


###
#     Triggers
###
clearTooltips = ->
  btns = document.querySelectorAll( ".btn-floating:hover" )
  $btns = $ btns
  $btns.mouseleave()
  $btns.mouseenter()
FlowRouter.triggers.enter [ clearTooltips ]
