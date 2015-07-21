###
#     Icon Directory (For Development Only)
###
FlowRouter.route '/icons',
  name: 'dev::MDI Icon Listing'
  action: ->
    FlowLayout.render 'icons'

FlowRouter.route '/datePicker',
  name: 'dev::Partial Date Picker'
  action: ->
    FlowLayout.render 'partialDatePickerSandbox'


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
#     List of Users
###
FlowRouter.route '/users',
  name: 'Users'
  subscriptions: ->
    @register "Users", Meteor.subscribe "Users"
  action: (params) ->
    FlowLayout.render 'app',
      main: 'users'
      controls: null


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
  action: (params) ->
    FlowLayout.render 'app',
      main: 'login'


###
#     Setup
###
FlowRouter.route '/setup',
  name: 'Setup'
  action: (params) ->
    FlowLayout.render 'app',
      main: 'establishURL'

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
