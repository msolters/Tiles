#   Template helpers, events, et cetera for the client.

Template.registerHelper 'profileName', ->
  user = Meteor.users.findOne()
  name = user.profile.name if user?
  return name if name?
Template.registerHelper 'hasDates', (tile) ->
  if tile?
    if tile.dates?
      if (d for d of tile.dates).length > 0
        return true
  return false
Template.registerHelper 'formatTileDates', (dates) ->
  if dates.dateOne? and dates.dateTwo?
    return "#{moment(dates.dateOne).format('MMMM, YYYY')} - #{moment(dates.dateTwo).format('MMMM, YYYY')}"
  else if dates.dateOne?
    return "#{moment(dates.dateOne).format('MMMM, YYYY')}"
  else
    return "#{moment(dates.dateTwo).format('MMMM, YYYY')}"
Template.registerHelper 'activeOrNot', (value) ->
  if value?
    switch typeof value
      when "string"
        if value.length > 0
          return "active"
      when "number"
        return "active"
Template.registerHelper 'textToHTML', (text) ->
  text.replace(/(\r\n\r\n|\n\n|\r\r)/gm,"<br/><br/>") if text?
Template.registerHelper 'currentlyEditing', ->
  return Session.get "currentlyEditing"
Template.registerHelper 'currentlyViewing', ->
  return Session.get "currentlyViewing"

#
#   Template.allTiles
#
Template.allTiles.rendered = ->
  data = Template.currentData()
  @autorun =>
    if data.categories.length is 0
      if Meteor.userId()
        toast "Now that you're logged in, you can create new tiles from the right-side menu!", 15000, "success"
        $('#right-menu').sidebar 'show'
      else
        toast "Looks like you need to add some content.<br>Sign in using the menu in the top right!", 15000, "info"
        $('#right-menu').sidebar 'show'
  if data.show_tile_id? # if the user passed a hash, see if its a Tile and open it in the modal!
    for category in data.categories
      for tile in category.tiles
        if tile._id is data.show_tile_id
          tileViewModal tile
          return
    toast "The URL you're looking for no longer exists!", 5000, "danger"


#
#   Template.tile
#
Template.tile.events
  'click a.tile-read-more': (event, template) ->
    data = Template.currentData()
    tileViewModal data.tile
  'click a.tile-edit': ->
    data = Template.currentData()
    tileEditModal.open data.tile
  'click a.tile-delete': ->
    data = Template.currentData()
    Session.set "setToDelete", data.tile._id
    modal = $('#delete-tile-confirmation')
    modal.openModal()


Template.tileViewModal.rendered = ->
  console.log "hi"
  Session.setDefault "currentlyViewing", null


#
#   Template.tileEditModal
#
Template.tileEditModal.rendered = ->
  instantiateTileEditModal @
Template.tileEditModal.events
  'click #save-tile-edit': (event, template) ->
    tileEditModal.showLoading()

    _tile = tileEditModal.getTile()
    if _tile.errors?  #Something critical like a title or category is missing!  Abort save.
      for e in _tile.errors
        toast e, 6500, "danger"
      return false
    else # Save that shit!
      _id = _tile._id
      delete _tile['_id']
      Meteor.call "saveTile", _tile, _id, (error, response) ->
        if error
          toast "Error saving tile: #{error}", 6000, "danger"
          tileEditModal.hideLoading()
        else
          toast "Tile saved successfully!", 4000, "success"
          tileEditModal.close()
    return false


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


#
#   Template.rightMenu
#
Template.rightMenu.rendered = ->
  $('#right-menu').sidebar 'setting', 'transition', 'overlay'

Template.rightMenu.events
  'click a.add-new-tile': ->
    $('#right-menu').sidebar 'hide'
    tileEditModal.open()
  'click a[data-login]': ->
    $('#right-menu').sidebar 'hide'
    $('#login-modal').openModal()
    $('#user-email').focus()
  'click a[data-logout]': ->
    $('#right-menu').sidebar 'hide'
    Meteor.logout()
    $('.toast').remove()
    toast "Take us out of orbit, Mr. Sulu.  Warp 1.", 3000, "success"


#
#     Template.register
#
Template.register.rendered = ->
  toast "Welcome to TilesJS!", 20000, "success"
  setTimeout ->
      toast "Create an account to get started.", 20000, "info"
    , 900

Template.register.events
  'submit form#register-form': (event, template) ->
    name = template.find('input#user-profile-name').value
    email = template.find('input#user-email').value
    password = template.find('input#user-password').value
    passwordConfirm = template.find('input#user-password-confirm').value
    if name.length is 0
      toast "Please enter a name!  Seriously, this is going to be your website.  That's your name up there.  Don't you even care?", 5000, "danger"
      return false
    if email.length is 0
      toast "Please enter a valid e-mail address!", 5000, "danger"
      return false
    if password.length < 6
      toast "Password must be 6 characters or more.", 5000, "danger"
      return false
    else
      if password isnt passwordConfirm
        toast "Those passwords don't match!", 5000, "danger"
        return false
    Meteor.call "createNewUser", email, password, name, (error, response) ->
      if error
        toast "Ya fucked up now!  #{error}", 5000, "danger"
      else
        Meteor.loginWithPassword email, password
        $(".toast").remove()
        toast "Nice work, bone daddy!  Can I call you #{name.split(' ')[0]}?", 20000, "success"
        setTimeout =>
          toast "(Simply click or swipe these messages to dismiss)", 20000, "info"
        , 1500
    return false


#
#   Template.login
#
Template.login.events
  'submit form#login-form': (event, template) ->
    email = template.find('input#user-email').value
    password = template.find('input#user-password').value
    if email.length is 0
      toast "Please enter a valid e-mail address!", 5000, "danger"
      return false
    if password.length is 0
      toast "Please enter a valid password!", 5000, "danger"
      return false
    Meteor.loginWithPassword email, password, (error) ->
      if error
        toast "Ya fucked up now!  #{error}", 5000, "danger"
      else
        given_name = "Asshole"
        if Meteor.user().profile?
          if Meteor.user().profile.name?
            given_name = Meteor.user().profile.name.split(' ')[0] if Meteor.user().profile.name.split(' ')[0].length > 0
        toast "Welcome back, #{given_name}!", 7000, "success"
        if given_name is "Asshole"
          toast "Hey you should probably fill in your name (top left).", 7000, "info"
        $(template.find('#login-modal')).closeModal()
    return false


#
#     Template.deleteTileConfirmation
#
Template.deleteTileConfirmation.events
  'click button[data-delete-tile]': ->
    Meteor.call "deleteTile", Session.get("setToDelete"), (err, resp) ->
      if err?
        toast "Error removing tile: #{err}", 7500, "danger"
      else
        toast "Tile successfully deleted!", 4000, "success"
