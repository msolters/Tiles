###
#   Template.confirmCancelControls
###
Template.confirmCancelControls.events
  'click a.btn-floating': (event, template) ->
    $(event.currentTarget).mouseleave()
