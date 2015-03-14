class @TileEditModal
  constructor: (@template) ->
    # First we just define jQuery handles for all the parts of the tileEditModal:
    @modal = $ @template.find '#tile-edit-modal'
    @progress = @modal.find '.progress'
    @title = @modal.find 'input#tile-title'
    @category = @modal.find 'input#tile-category'
    @dateOne = @modal.find('input#date-one').pickadate()
    @datePickerOne = @dateOne.pickadate "picker"
    @dateTwo = @modal.find('input#date-two').pickadate()
    @datePickerTwo = @dateTwo.pickadate "picker"
    @content = @modal.find 'textarea#tile-content'

    # Next we define datePicker callback behaviour for setting, clearing, and label animations
    processDateSetEvent = (picker, thingSet) ->
      for thing, setValue of thingSet
        if thing is "clear"
          picker.$node.parent().find('label').removeClass "active"
        else if thing is "select"
          picker.$node.parent().find('label').addClass "active"
    @datePickerOne.on
      set: (thingSet) -> processDateSetEvent @, thingSet
    @datePickerTwo.on
      set: (thingSet) -> processDateSetEvent @, thingSet

  #  Set and configure the values of the tileEditModal inputs
  setData: (tile) ->
    Session.set "currentlyEditing", tile
    if tile?
      if tile.dates?
        @datePickerOne.set "select", tile.dates.dateOne if tile.dates.dateOne?
        @datePickerTwo.set "select", tile.dates.dateTwo if tile.dates.dateTwo?
      return
    @modal.find("input").val ""
    @modal.find("textarea").val ""
    @modal.find("label").removeClass "active"
    @datePickerOne.clear()
    @datePickerTwo.clear()

  # Return either a JSON representation of the tile values as
  # entered by the user, or a list of errors to be shown such
  # as missing a Title or Category.
  getTile: ->
    _errors = []
    if @title.val().length is 0
      _errors.push "Please enter a valid title for this Tile!"
    if @category.val().length is 0
      _errors.push "Please enter a valid category for this Tile!"
    if _errors.length > 0
      @hideLoading()
      return {errors: _errors}
    else
      # Set _id (this depends on if it's a new or pre-existing tile)
      if Session.get("currentlyEditing")?
        _id = Session.get("currentlyEditing")._id
      else
        _id = null
      # Check if the user selected any dates or if they were cleared
      if @datePickerOne.get().length is 0
        dateOne = null
      else
        dateOne = moment(@datePickerOne.get()).toDate()
      if @datePickerTwo.get().length is 0
        dateTwo = null
      else
        dateTwo = moment(@datePickerTwo.get()).toDate()
      tile =
        _id: _id
        title: @title.val()
        category: @category.val()
        content: @content.val()
        dates:
          dateOne: dateOne
          dateTwo: dateTwo
      return tile

  # Display the tileEditModal and populate it with the data
  # contained in the tile argument object.
  open: (tile=null) ->
    @setData tile
    @modal.openModal
      ready: =>
        $('textarea#tile-content').keydown()
        @hideLoading()

  # Close the tileEditModal.  If the optional argument reset
  # is true, clear the modal inputs.
  close: (reset=false) ->
    @modal.closeModal()
    @clearData() unless reset is false

  # Clears the inputs.
  clearData: ->
    @setData null

  # Display the progress bar at the bottom of the modal.
  showLoading: ->
    @progress.show()

  # Hide the progress bar at the bottom of the modal.
  hideLoading: ->
    @progress.hide()
