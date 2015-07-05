###
#   Template.app
###
Template.app.created = ->
  @autorun =>
    ifLoggedOut ->
      $(".tooltip").removeClass "show"
      $(".tooltip").addClass "hide"

Template.app.events
  'click a.btn-floating': ->
    $(".tooltip.show").removeClass("show").addClass("hide")
    btns = document.querySelectorAll( ".btn-floating:hover" )
    $btns = $ btns
    $btns.mouseleave()
    $btns.mouseenter()
