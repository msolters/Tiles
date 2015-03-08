@Tiles = new Mongo.Collection 'Tiles'

# Only server can create a user!
Accounts.config
  forbidClientAccountCreation: true

@userExists = ->
  if Meteor.users.find().count() > 0
    return true
  else
    return false

#   Open a modal to view a Tile in detail:
@tileViewModal = (tile) ->
  modal = $('#tile-view-modal')
  modal.find('.progress').show()
  Session.set "currentlyViewing", tile
  modal.openModal
    ready: ->
      modal.find('.progress').hide()
    complete: ->
      Router.go "#{window.location.pathname}"
  Router.go "#{window.location.pathname}##{tile._id}"

# Create a handler for the tileEditModal.
# Called on modal render.
@instantiateTileEditModal = (template) =>
  @tileEditModal = new TileEditModal template

#     Materialize Toast!
@toast = (message, displayLength, className, completeCallback) ->
  createToast = (html) ->
    `var container`
    ###
    switch className
      when "danger"
        html = "<i class='mdi-alert-error left'></i> #{html}"
    ###
    toast = $('<div class=\'toast\'></div>').addClass(className).html(html)
    # Bind hammer
    toast.hammer(prevent_default: false).bind('pan', (e) ->
      deltaX = e.gesture.deltaX
      activationDistance = 80
      #                  change toast state
      if !toast.hasClass('panning')
        toast.addClass 'panning'
      opacityPercent = 1 - Math.abs(deltaX / activationDistance)
      if opacityPercent < 0
        opacityPercent = 0
      toast.velocity {
        left: deltaX
        opacity: opacityPercent
      },
        duration: 50
        queue: false
        easing: 'easeOutQuad'
      return
    ).bind('panend', (e) ->
      deltaX = e.gesture.deltaX
      activationDistance = 80
      # If toast dragged past activation point
      if Math.abs(deltaX) > activationDistance
        toast.velocity { marginTop: '-40px' },
          duration: 375
          easing: 'easeOutExpo'
          queue: false
          complete: ->
            if typeof completeCallback == 'function'
              completeCallback()
            toast.remove()
            return
      else
        toast.removeClass 'panning'
        # Put toast back into original position
        toast.velocity {
          left: 0
          opacity: 1
        },
          duration: 300
          easing: 'easeOutExpo'
          queue: false
      return
    ).on 'click', ->
      toast.fadeOut 'fast', toast.remove
      return
    toast

  className = className or ''
  if $('#toast-container').length == 0
    # create notification container
    container = $('<div></div>').attr('id', 'toast-container')
    $('body').append container
  # Select and append toast
  container = $('#toast-container')
  newToast = createToast(message)
  container.append newToast
  toasts = container.find('.toast')
  if toasts.length >= 4
    for toast in [0..(toasts.length-4)]
      $(toasts[toast]).fadeOut 700, ->
        $(@).remove()


  newToast.css
    'top': parseFloat(newToast.css('top')) + 35 + 'px'
    'opacity': 0
  newToast.velocity {
    'top': '0px'
    opacity: 1
  },
    duration: 300
    easing: 'easeOutCubic'
    queue: false
  # Allows timer to be pause while being panned
  timeLeft = displayLength
  counterInterval = setInterval((->
    if newToast.parent().length == 0
      window.clearInterval counterInterval
    if !newToast.hasClass('panning')
      timeLeft -= 100
    if timeLeft <= 0
      newToast.velocity {
        'opacity': 0
        marginTop: '-40px'
      },
        duration: 375
        easing: 'easeOutExpo'
        queue: false
        complete: ->
          if typeof completeCallback == 'function'
            completeCallback()
          $(this).remove()
          return
      window.clearInterval counterInterval
    return
  ), 100)
  return
