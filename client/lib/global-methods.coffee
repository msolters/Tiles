@ifLoggedOut = (cb=null) ->
  if !Meteor.user()?
    if !Meteor.loggingIn()
      cb()

@ifLoggedIn = (cb=null) ->
  if Meteor.user()?
    cb()
