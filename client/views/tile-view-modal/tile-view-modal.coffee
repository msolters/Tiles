Template.tileViewModal.rendered = ->
  modal = $ "#tile-view-modal"
  # Set an autorun computation: whenever the
  # currentlyViewing session var changes,
  # open or close the modal appropriately.
  @autorun ->
    _id = Session.get "currentlyViewing"
    if !_id?
      console.log "close that shit"
      Router.go "#{window.location.pathname}"
      modal.closeModal()
    else
      modal.find('.progress').show()
      console.log "open that shit"
      modal.openModal
        ready: ->
          modal.find('.progress').hide()
          Router.go "#{window.location.pathname}##{_id}"
        complete: ->
          Session.set "currentlyViewing", null
          Router.go "#{window.location.pathname}"
