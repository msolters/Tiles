###
#   Template.tileBigEdit
###
Template.tileBigEdit.created = ->
  @t0 = new ReactiveVar 0
  @t0.set @data.tile.t0
  @t1 = new ReactiveVar 0
  @t1.set @data.tile.t1

Template.tileBigEdit.rendered = ->
  @contentEdit = $ @find "#tile-edit-content"
  @contentEdit.editable
    inlineMode: false

Template.tileBigEdit.helpers
  t0: -> Template.instance().t0
  t1: -> Template.instance().t1

Template.tileBigEdit.events
  'click button[data-save-tile]': (event, template) ->
    #
    # (1) First, define _tile as the Tile as we have it
    #     currently in the database.
    #
    _tile = template.data.tile
    #
    # (1) Get the Tile ID.
    #
    if _tile._id?
      tID = template.data.tile._id
    else
      tID = "new"
    #
    # (2) Validate & Construct a Tile object
    #
    _tile.title = template.find('input#tile-title').value
    _tile.category = template.find('input#tile-category').value
    _errors = []
    if !nonEmptyString _tile.title
      _errors.push "Please enter a valid title for this Tile!"
    if !nonEmptyString _tile.category
      _errors.push "Please enter a valid category for this Tile!"
    if _errors.length > 0
      for error in _errors
        toast error, 4500, "danger"
      return
    #
    # (3) Once we are sure there is a Title and a Category,
    #     convert content from HTML to searchable plaintext.
    #
    _tile.content = template.contentEdit.editable "getHTML"
    $("body").append("<div id='render-html'>#{_tile.content}</div>")
    _tile.searchableContent = $("#render-html").text()
    $("#render-html").remove()
    #
    # (5) Get dates!
    #
    _tile.t0 = template.t0.get()
    _tile.t1 = template.t1.get()
    #
    # (4) Save the Tile!
    #
    Meteor.call "saveTile", _tile, (error, response) ->
      if error
        toast "Error saving tile: #{error}", 6000, "danger"
      else
        toast "Tile saved successfully!", 4000, "success"
        Materialize.modalize.close()
