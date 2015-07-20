###
#   Template.users
###
Template.users.helpers
  users: ->
    Meteor.users.find({}, {fields: {profile: 1}}).fetch()
