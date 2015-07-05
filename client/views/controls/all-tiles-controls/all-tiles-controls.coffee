###
#   Template.allTilesControls
###
Template.allTilesControls.created = ->
  #
  # (1) Establish Reactive response to user's logged in status
  #     to automatically open/close the menu for them.
  #
  @autorun =>
    ifLoggedIn ->
      Meteor.setTimeout ->
        Session.set "menuOpen", true
      , 15
    ifLoggedOut ->
      Session.set "menuOpen", false

  #
  # (2) Create ReactiveVars to control Tile & Category sorting
  #
  @sortingTiles = new ReactiveVar 0
  @sortingCategories = new ReactiveVar 0

Template.allTilesControls.helpers
  open: ->
    return Session.get "menuOpen"
  currentlySorting: ->
    if Template.instance().sortingTiles.get() or Template.instance().sortingCategories.get()
      return true
    else
      return false
  currentlySortingTiles: ->
    return Template.instance().sortingTiles.get()
  currentlySortingCategories: ->
    return Template.instance().sortingCategories.get()

Template.allTilesControls.events
  'click a[data-logout]': ->
    Meteor.logout()
    $('.toast').remove()
    toast "Take us out of orbit, Mr. Sulu.  Warp 1.", 3000, "success"
  'click a[data-login]': ->
    MaterializeModal.custom
      title: 'Login'
      bodyTemplate: 'loginForm'
      modal: true
    $('#user-email').focus()
  'click a[data-toggle-menu]': (event, template) ->
    _currentState = Session.get 'menuOpen'
    Session.set 'menuOpen', !_currentState
  ###
  #   Buttons to begin the Tile & Category sorting algorithms:
  ###
  'click a[data-tile-sort]': (event, template) ->
    template.sortingTiles.set true
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
    template.tileSortable.option "disabled", false
    toast "Drag n' drop tiles to change their order.  Make sure to click Done to save your changes!", 3500, "success"
  'click a[data-category-sort]': (event, template) ->
    template.sortingCategories.set true
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
    template.categorySortable.option "disabled", false
    $('.tile').hide()
    toast "Drag n' drop categories to change their order.  Make sure to click Done to save your changes!", 3500, "success"
