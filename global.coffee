@Tiles = new Mongo.Collection 'Tiles'

#   Open a modal to view a Tile in detail:
@tileViewModal = (tile) ->
  modal = $('#tile-view-modal')
  modal.find('.modal-content').html "<h3>#{tile.title}</h3><p>#{tile.content}</p>"
  modal.openModal
    complete: ->
      Router.go "#{window.location.pathname}"
  Router.go "#{window.location.pathname}##{tile._id}"

#   Open a modal to edit a Tile in detail:
@openTileEditModal = (tile=null) ->
  modal = $('#tile-edit-modal')
  if tile is null
    tile =
      _id: null
      title: ''
      category: ''
      content: ''
  Session.set "currentlyEditing", tile._id
  modal_html = "<div class='title'>
    <div class='input-field'>
      <input id='tile-title' type='text' class='tile-title validate' value='#{tile.title}'>
      <label for='tile-title'"

  if tile.title.length > 0
    modal_html += "class='active'"

  modal_html += ">Title</label>
    </div>
    <div class='input-field'>
      <input id='tile-category' type='text' class='tile-category validate' value='#{tile.category}'>
      <label for='tile-category'"

  if tile.category.length > 0
    modal_html += "class='active'"

  modal_html += ">Category</label>
    </div>
    </div>
    <div class='content'>
    <div class='input-field'>
      <textarea id='tile-content' class='materialize-textarea tile-content'>#{tile.content}</textarea>
      <label for='tile-content'"

  if tile.content.length > 0
    modal_html += "class='active'"

  modal_html += ">Content</label>
    </div>
    </div>"

  modal.find('.modal-content').html modal_html
  modal.openModal
    complete: ->
      #Router.go "#{window.location.pathname}"
  #Router.go "#{window.location.pathname}##{tile._id}"

@closeTileEditModal = ->
  modal = $('#tile-edit-modal')
  modal.closeModal()
  modal.find('.progress').hide()
  modal.find('input, textarea').val ""

#   To disable the user registration or not...
Meteor.call "getNumberUsers", (error, response) ->
  Accounts.config
    forbidClientAccountCreation: response

#     Materialize Toast!
@toast = (message, displayLength, className, completeCallback) ->
  createToast = (html) ->
    `var container`
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
