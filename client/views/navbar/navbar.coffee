#
#   Template.navbar
#
Template.navbar.events
  'input input#tile-search': (event, template) ->
    _search = event.currentTarget.value
    template.data.searchVar.set _search
    searchBar = $(event.currentTarget).parent()
    icon = searchBar.find 'i'
    if _search.length > 0
      icon.removeClass "mdi-action-search"
      icon.addClass "mdi-content-clear pointer"
      searchBar.addClass "active"
    else
      icon.addClass "mdi-action-search"
      icon.removeClass "mdi-content-clear pointer"
  'click .mdi-content-clear': (event, template) ->
    template.find("input#tile-search").value = ""
    icon = $(event.currentTarget).parent().find 'i'
    icon.addClass "mdi-action-search"
    icon.removeClass "mdi-content-clear pointer"
    template.data.searchVar.set null
  'focus input#tile-search': (event, template) ->
    searchBar = $(event.currentTarget).parent()
    searchBar.addClass "active"
  'blur input#tile-search': (event, template) ->
    Meteor.setTimeout ->
      searchBar = $(event.currentTarget).parent()
      searchBar.removeClass "active"
    , 100
