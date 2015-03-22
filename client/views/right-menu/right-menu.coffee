#
#   Template.rightMenu
#
Template.rightMenu.rendered = ->
  $('#right-menu').sidebar 'setting', 'transition', 'overlay'

Template.rightMenu.events
  #   USER CONFIGURATION
  'click a[data-login]': ->
    $('#right-menu').sidebar 'hide'
    $('#login-modal').openModal()
    $('#user-email').focus()
  'click a[data-logout]': ->
    $('#right-menu').sidebar 'hide'
    Meteor.logout()
    $('.toast').remove()
    toast "Take us out of orbit, Mr. Sulu.  Warp 1.", 3000, "success"
  'click a[data-change-url]': ->
    $('#right-menu').sidebar 'hide'
    Router.go 'Setup'


#
#   Template.editTileMenu
#
Template.editTileMenu.events
  'click a[data-cancel-edit]': ->
    $("#right-menu").sidebar "hide"
    Router.go "/#{Meteor.user().profile.public_url}"
  'click a[data-save-edit]': ->
    $("#right-menu").sidebar "hide"
    _tile = Session.get "currentlyEditing"
    _tile.category = $("input#tile-category").focusout().val()
    _errors = []
    if !nonEmptyString _tile.title
      _errors.push "Please enter a valid title for this Tile!"
    if !nonEmptyString _tile.category
      _errors.push "Please enter a valid category for this Tile!"
    if _errors.length > 0
      #@hideLoading()
      for error in _errors
        toast error, 4500, "danger"
      return
    else
      # Set _id (this depends on if it's a new or pre-existing tile)
      if _tile._id?
        _id = _tile._id
        delete _tile['_id']
      else
        _id = null

      # Convert preview and body content from HTML -> Text, for keyword searching:
      $("body").append("<div id='render-html'>#{_tile.content} #{_tile.preview}</div>")
      searchableContent = $("#render-html").text()
      $("#render-html").remove()

      _tile.searchableContent = searchableContent
      Meteor.call "saveTile", _tile, _id, (error, response) ->
        if error
          toast "Error saving tile: #{error}", 6000, "danger"
        else
          toast "Tile saved successfully!", 4000, "success"
          Router.go "/#{Meteor.user().profile.public_url}"


#
#   Template.manageTilesMenu
#
Template.manageTilesMenu.helpers
  'tileSortable': ->
    t = 0
    for cat in Session.get "categories"
      for _id in cat.tile_ids
        t++
        if t > 1
          return true
    return false
  'categorySortable': ->
    if Session.get("categories").length > 1
      return true
    return false
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

Template.manageTilesMenu.events
  'click a.add-new-tile': ->
    $('#right-menu').sidebar 'hide'
    Router.go '/edit/new'
  'click a[data-cancel-sort-tiles]': (event, template) ->
    $('#right-menu').sidebar 'hide'
    toast "Reverting...", 2500, "info"
    template.tileSortable.option "disabled", true
    Session.set "tileSortableDisabled", true
    renderTrigger.changed()
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
  'click a[data-cancel-sort-categories]': (event, template) ->
    $('#right-menu').sidebar 'hide'
    toast "Reverting...", 2500, "info"
    template.categorySortable.option "disabled", true
    Session.set "categorySortableDisabled", true
    renderTrigger.changed()
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
      $('.tile').show()
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
