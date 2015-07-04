###
#   Template.app
###
Template.app.created = ->
  @autorun =>
    ifLoggedOut ->
      $(".tooltip").removeClass "show"
      $(".tooltip").addClass "hide"
