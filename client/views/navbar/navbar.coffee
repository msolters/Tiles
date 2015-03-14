#
#   Template.navbar
#
Template.navbar.events
  'click a[data-sidebar]': ->
    $('#right-menu').sidebar 'show'
  'input input#user-profile-name': (event, template) ->
    clearTimeout template.nameTimer if template.nameTimer?
    _profile_name = event.currentTarget.value
    _user =
      profile:
        name: _profile_name
    template.nameTimer = setTimeout =>
      Meteor.call "updateUser", Meteor.userId(), _user
    , 200
