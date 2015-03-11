#   Template helpers, events, et cetera for the client.
Template.registerHelper 'profileName', ->
  url = Router.current().params.publicURL
  db_user = Meteor.users.findOne({public_url: url})
  name = db_user.profile.name if db_user?
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
  _tile = Session.get("currentlyEditing")
  if _tile?
    return _tile
  else
    return null
Template.registerHelper 'currentlyViewing', ->
  return Session.get "currentlyViewing"
Template.registerHelper 'verify', (user) ->
  url = Router.current().params.publicURL
  if Meteor.user()?
    db_url = Meteor.user().public_url
    if db_url?
      if url is db_url
        return true
  return false

#
#   Template.allTiles
#
Template.allTiles.rendered = ->
  data = @data
  @autorun =>
    data=Template.currentData()
    if $("#tile-container-inner")[0]?
      Blaze.remove(Blaze.getView($("#tile-container-inner")[0]))
    Blaze.renderWithData Template.categories, data, @find("#tile-container")
  if data.categories.length is 0
    if Meteor.user().public_url is data.public_url
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


#
#   Template.tileEditModal
#
Template.tileEditModal.rendered = ->
  instantiateTileEditModal @
Template.tileEditModal.events
  'click #save-tile-edit': (event, template) ->
    tileEditModal.showLoading()
    _tile = tileEditModal.getTile() # get user's changes
    if _tile.errors?  #Something critical like a title or category is missing!  Abort save.
      for e in _tile.errors
        toast e, 6500, "danger"
      return false
    else # Save that shit!
      if !_tile._id?  # tile is new!
        pos = {}
        k = 0
        for cat, i in @categories
          if cat.title is _tile.category
            _tile.pos =
              category: i
              tile: cat.tiles.length
            break
          else
            k++
        if !_tile.pos? # no matching category!  add tile in last category, first tile position.
          _tile.pos =
            category: k
            tile: 0
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

Template.rightMenu.helpers
  'tileSortActive': ->
    if Session.get("tileSortableDisabled")?
      return !Session.get("tileSortableDisabled")
    else
      return false
  'categorySortActive': ->
    if Session.get("categorySortableDisabled")?
      return !Session.get("categorySortableDisabled")
    else
      return false

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
  'click a[data-sort-tiles]': (event, template) ->
    if !template.tileSortable? # if sortable hasn't been instantiated, instantiate it!
      template.tileSortable = new Sortable $("#tile-container")[0],
        group: "tileSortable"  # or { name: "...", pull: [true, false, clone], put: [true, false, array] }
        sort: true  # sorting inside list
        disabled: true # Disables the sortable if set to true.
        store: null  # @see Store
        animation: 150  # ms, animation speed moving items when sorting, `0` — without animation
        #handle: ".tile-action-row"  # Drag handle selector within list items
        filter: ".category-title"  # Selectors that do not lead to dragging (String or Function)
        draggable: ".tile"  # Specifies which items inside the element should be sortable
        ghostClass: "tile-placeholder"  # Class name for the drop placeholder
        scroll: true # or HTMLElement
        scrollSensitivity: 30 # px, how near the mouse must be to an edge to start scrolling.
        scrollSpeed: 10 # px
    tileSortableDisabled = !template.tileSortable.option "disabled"
    template.tileSortable.option "disabled", tileSortableDisabled
    Session.set "tileSortableDisabled", tileSortableDisabled
    if tileSortableDisabled is false  #sorting enabled
      toast "Drag n' drop tiles to change their order.  Make sure to click Done to save your changes!", 3500, "success"
      setTimeout ->
        $('#right-menu').sidebar('hide')
      , 350
    else  # sorting disabled, time to save
      $('#right-menu').sidebar 'hide'
      toast "Saving changes...", 3000, "info"
      $("#pusher-container > .progress").show()
      tilePositions = {}
      currentCat = null
      for child in $('#tile-container').children()
        $child = $ child
        if $child.is(".category-title")
          currentCat = Blaze.getData(child).title
          tilePositions[currentCat] = []
        if $child.is(".tile")
          tilePositions[currentCat].push Blaze.getData(child).tile._id
      k = 0
      pending = 0
      for cat, tileList of tilePositions
        pending += tileList.length

      for cat, tileList of tilePositions
        for _id, i in tileList
          _tile =
            category: cat
            pos:
              tile: i
              category: k
          Meteor.call "saveTile", _tile, _id, (err, resp) ->
            if err?
              pending -= 1
              toast "Problem saving new position of tile #{_id}!  Skipping...", 4000, "danger"
            else
              pending -= 1
              console.log pending
              if pending is 0
                toast "New arrangement committed to database successfully!", 4000, "success"
                $("#pusher-container > .progress").hide()
        k++
  'click a[data-sort-categories]': (event, template) ->
    if !template.categorySortable? # if sortable hasn't been instantiated, instantiate it!
      template.categorySortable = new Sortable $("#tile-container")[0],
        group: "categorySortable"  # or { name: "...", pull: [true, false, clone], put: [true, false, array] }
        sort: true  # sorting inside list
        disabled: true # Disables the sortable if set to true.
        store: null  # @see Store
        animation: 150  # ms, animation speed moving items when sorting, `0` — without animation
        #handle: ".tile-action-row"  # Drag handle selector within list items
        filter: ".tile"  # Selectors that do not lead to dragging (String or Function)
        draggable: ".category-title"  # Specifies which items inside the element should be sortable
        ghostClass: "tile-placeholder"  # Class name for the drop placeholder
        scroll: true # or HTMLElement
        scrollSensitivity: 30 # px, how near the mouse must be to an edge to start scrolling.
        scrollSpeed: 10 # px

    # (1) we toggle the disabled value!
    categorySortableDisabled = !template.categorySortable.option "disabled"
    template.categorySortable.option "disabled", categorySortableDisabled
    Session.set "categorySortableDisabled", categorySortableDisabled

    # (2) process those values!
    if categorySortableDisabled is false  #sorting enabled
      $('.tile').hide()
      toast "Drag n' drop categories to change their order.  Make sure to click Done to save your changes!", 3500, "success"
      setTimeout ->
        $('#right-menu').sidebar('hide')
      , 350
    else                      # sorting disabled, time to save
      $('#right-menu').sidebar 'hide'
      toast "Saving changes...", 3000, "info"
      $("#pusher-container > .progress").show()
      categoryPositions = (Blaze.getData(child).title for child in $('#tile-container').find('.category-title'))
      pending = categoryPositions.length
      for category, pos in categoryPositions
        _query =
          category: category
        _update =
          "pos.category": pos
        Meteor.call "updateTiles", _query, _update, (err, resp) ->
          if err?
            pending -= 1
            toast "Problem saving new position of category #{category}!  Skipping...", 4000, "danger"
          else
            pending -= 1
            console.log pending
            if pending is 0
              toast "New arrangement committed to database successfully!", 4000, "success"
              $('.tiles').show()
              $("#pusher-container > .progress").hide()


#
#     Template.register
#
Template.register.rendered = ->
  toast "Welcome to TilesJS!", 20000, "success"
  $("input#user-profile-name").focus()
  setTimeout ->
      toast "Create an account to get started.", 20000, "info"
    , 900

Template.register.events
  'focus input#user-url': (event, template) ->
    if !Session.get("urlExplained")?
      toast "This will be the URL you can access your page from, i.e. <b>http://#{window.location.hostname}/mypagehere</b>", 3500, "info"
      Session.set("urlExplained", true)
  'submit form#register-form': (event, template) ->
    name = template.find('input#user-profile-name').value
    email = template.find('input#user-email').value
    password = template.find('input#user-password').value
    passwordConfirm = template.find('input#user-password-confirm').value
    url = template.find('input#user-url').value.toLowerCase()
    if name.length is 0
      toast "Please enter a name!  Seriously, this is going to be your website.  That's your name up there.  Don't you even care?", 5000, "danger"
      return false
    if email.length is 0
      toast "Please enter a valid e-mail address!", 5000, "danger"
      return false
    if password.length <= 6
      toast "Password must be 6 characters or more.", 5000, "danger"
      return false
    else
      if password isnt passwordConfirm
        toast "Those passwords don't match!", 5000, "danger"
        return false
    if url.length is 0
      toast "Please enter a profile URL!", 5000, "danger"
      return false
    else
      url_encoded = encodeURIComponent url
      if url isnt url_encoded
        toast "People would have to type <b>http://#{window.location.hostname}/#{url_encoded}</b> to get to your page!!  Are you out of your magnificient mind?  Pick a better URL!  (Avoid spaces, slashes and weird characters.)", 6500, "danger"
        return false
      else
        url = url_encoded
    Meteor.call "verifyURL", url, (error, response) ->
      if error
        toast "Ya fucked up now!  #{error}", 5000, "danger"
      else
        if response is true
          Meteor.call "createNewUser", email, password, name, url, (error, response) ->
            if error?
              toast "Ya fucked up now!  #{error}", 5000, "danger"
            else
              if response.success is true
                Meteor.loginWithPassword email, password
                $(".toast").remove()
                Deps.autorun =>
                  if Meteor.userId()?
                    Router.go "/#{url}"
                toast "Nice work, bone daddy!  Can I call you #{name.split(' ')[0]}?", 15000, "success"
                setTimeout =>
                  toast "(Simply click or swipe these messages to dismiss)", 15000, "info"
                , 1500
              else
                toast response.msg, 6500, "danger"
        else
          toast "That URL is already taken!  Please choose another.", 6500, "danger"
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
#     Template.socialLogin
#
Template.socialLogin.events
  'click button#facebook-account': (event, template) ->
    switch @action
      when "register"
        url = $("#user-url").val()
        if url.length is 0
          toast "Please enter a profile URL above!", 5000, "danger"
          $("#user-url").focus()
          return false
        else
          url_encoded = encodeURIComponent url
          if url isnt url_encoded
            toast "People would have to type <b>http://#{window.location.hostname}/#{url_encoded}</b> to get to your page!!  Are you out of your magnificient mind?  Pick a better URL!  (Avoid spaces, slashes and weird characters.)", 6500, "danger"
            return false
          else
            url = url_encoded
        Meteor.call "verifyURL", url, (error, response) ->
          if error
            toast "Ya fucked up now!  #{error}", 5000, "danger"
          else
            if response is true
              Meteor.loginWithFacebook()
              template.facebookWaiter.stop() if template.facebookWaiter?
              template.facebookWaiter = Deps.autorun =>
                if Meteor.userId()?
                  Meteor.call "updateUser", {public_url: url}, (err, response) ->
                    if !err?
                      Router.go "/#{url}"
                      toast "Nice work, bone daddy!  Can I call you #{Meteor.user().profile.name.split(' ')[0]}?", 15000, "success"
                      setTimeout =>
                        toast "(Simply click or swipe these messages to dismiss)", 15000, "info"
                      , 1500
            else
              toast "That URL is already taken!  Please choose another.", 6500, "danger"
      when "login"
        Meteor.loginWithFacebook()
        template.facebookWaiter.stop() if template.facebookWaiter?
        template.facebookWaiter = Deps.autorun =>
          if Meteor.userId()?
            given_name = "Asshole"
            if Meteor.user().profile?
              if Meteor.user().profile.name?
                given_name = Meteor.user().profile.name.split(' ')[0] if Meteor.user().profile.name.split(' ')[0].length > 0
            toast "Welcome back, #{given_name}!", 7000, "success"
            if given_name is "Asshole"
              toast "Hey you should probably fill in your name (top left).", 7000, "info"
            $('#login-modal').closeModal()
  'click button#google-account': (event, template) ->
    switch @action
      when "register"
        url = $("#user-url").val()
        if url.length is 0
          toast "Please enter a profile URL above!", 5000, "danger"
          $("#user-url").focus()
          return false
        else
          url_encoded = encodeURIComponent url
          if url isnt url_encoded
            toast "People would have to type <b>http://#{window.location.hostname}/#{url_encoded}</b> to get to your page!!  Are you out of your magnificient mind?  Pick a better URL!  (Avoid spaces, slashes and weird characters.)", 6500, "danger"
            return false
          else
            url = url_encoded
        Meteor.call "verifyURL", url, (error, response) ->
          if error
            toast "Ya fucked up now!  #{error}", 5000, "danger"
          else
            if response is true
              Meteor.loginWithGoogle()
              template.googleWaiter.stop() if template.googleWaiter?
              template.googleWaiter = Deps.autorun =>
                if Meteor.userId()?
                  Meteor.call "updateUser", {public_url: url}, (err, response) ->
                    if !err?
                      Router.go "/#{url}"
                      toast "Nice work, bone daddy!  Can I call you #{Meteor.user().profile.name.split(' ')[0]}?", 15000, "success"
                      setTimeout =>
                        toast "(Simply click or swipe these messages to dismiss)", 15000, "info"
                      , 1500
            else
              toast "That URL is already taken!  Please choose another.", 6500, "danger"
      when "login"
        Meteor.loginWithGoogle()
        template.googleWaiter.stop() if template.googleWaiter?
        template.googleWaiter = Deps.autorun =>
          if Meteor.userId()?
            given_name = "Asshole"
            if Meteor.user().profile?
              if Meteor.user().profile.name?
                given_name = Meteor.user().profile.name.split(' ')[0] if Meteor.user().profile.name.split(' ')[0].length > 0
            toast "Welcome back, #{given_name}!", 7000, "success"
            if given_name is "Asshole"
              toast "Hey you should probably fill in your name (top left).", 7000, "info"
            $('#login-modal').closeModal()

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
