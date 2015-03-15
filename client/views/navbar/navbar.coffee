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
  'input input#tile-search': (event, template) ->
    _search = event.currentTarget.value
    Session.set "search", _search
    icon = $(event.currentTarget).parent().find 'i'
    if _search.length > 0
      icon.removeClass "mdi-action-search"
      icon.addClass "mdi-content-clear pointer"
    else
      icon.addClass "mdi-action-search"
      icon.removeClass "mdi-content-clear pointer"
  'click #tile-search-prefix': (event, template) ->
    template.find("input#tile-search").value = ""
    Session.set "search", null
