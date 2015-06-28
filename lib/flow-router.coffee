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
    FlowLayout.render 'internalLayout',
      main: 'home'


###
#     Register
###
FlowRouter.route '/register',
  name: 'Register'
  subscriptions: (params, qParams) ->
  action: (params) ->
    FlowLayout.render 'externalLayout',
      main: 'register'


###
#     Loading
###
###
FlowRouter.route '/',
  name: 'Home'
  subscriptions: (params, qParams) ->
  action: (params) ->
    FlowLayout.render 'internalLayout',
      main: 'loading'
###


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
  action: (params) ->
    FlowLayout.render 'internalLayout',
      main: 'allTiles'
