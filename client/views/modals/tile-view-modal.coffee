Template.tileViewModal.rendered = ->
  modal = $ "#tile-view-modal"
  # Set an autorun computation: whenever the
  # currentlyViewing session var changes,
  # open or close the modal appropriately.
  @autorun ->
    _id = Session.get "currentlyViewing"
    if !_id?
      #console.log "close that shit"
      FlowRouter.go "#{window.location.pathname}"
      modal.closeModal()
    else
      #console.log "open that shit"
      modal.find('.progress').show()
      modal.openModal
        ready: ->
          modal.find('.progress').hide()
          FlowRouter.go "#{window.location.pathname}##{_id}"
        complete: ->
          #console.log "done"
          Session.set "currentlyViewing", null
          FlowRouter.go "#{window.location.pathname}"

Template.tileViewModal.events
  'click button#close-view-modal': ->
    Session.set "currentlyViewing", null
