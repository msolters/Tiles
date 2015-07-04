#
#   Template.navbar
#
Template.navbar.events
  'input input#user-profile-name': (event, template) ->
    clearTimeout template.nameTimer if template.nameTimer?
    _profile_name = event.currentTarget.value
    _user =
      "profile.name": _profile_name
    template.nameTimer = setTimeout =>
      Meteor.call "updateUser", _user
    , 200
  'input input#tile-search': (event, template) ->
    _search = event.currentTarget.value
    template.data.searchVar.set _search
    icon = $(event.currentTarget).parent().find 'i'
    if _search.length > 0
      icon.removeClass "mdi-action-search"
      icon.addClass "mdi-content-clear pointer"
    else
      icon.addClass "mdi-action-search"
      icon.removeClass "mdi-content-clear pointer"
  'click #tile-search-prefix': (event, template) ->
    template.find("input#tile-search").value = ""
    icon = $(event.currentTarget).parent().find 'i'
    icon.addClass "mdi-action-search"
    icon.removeClass "mdi-content-clear pointer"
    template.data.searchVar.set null
