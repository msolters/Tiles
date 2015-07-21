###
#   Template.partialDatePickerSandbox
###
Template.partialDatePickerSandbox.created = ->
  @dateObj = new ReactiveVar 0
  @dateObj.set
    precision: 'days'
    timestamp: moment().toDate()

Template.partialDatePickerSandbox.helpers
  dateObj: ->
    Template.instance().dateObj
  dateObjPreview: ->
    _dateObj = Template.instance().dateObj.get()
    return "Timestamp: #{moment(_dateObj.timestamp).format()}<br>Precision:#{_dateObj.precision}"




###
#   Template.partialDatePicker
###
Template.partialDatePicker.created = ->
  #
  # (1) Initialize Variables
  #
  @precisionMap =
    0: null
    1: 'years'
    2: 'months'
    3: 'days'
  @precision = new ReactiveVar 0
  @dateParts = new ReactiveMap()

  #
  # (2) Check if the passed-in date already has been configured.
  #
  _date = @data.date.get()
  if _date is null
    # No pre-existing date, configure blank picker.
    @precision.set 0
  else
    # There already exists a date configuration render whatever that date is.
    _timestamp = moment _date.timestamp
    switch _date.precision
      when 'years'
        @precision.set 1
        @dateParts.set
          year: _timestamp.get 'year'
      when 'months'
        @precision.set 2
        @dateParts.set
          year: _timestamp.get 'year'
          month: _timestamp.get 'month'
      when 'days'
        @precision.set 3
        @dateParts.set
          year: _timestamp.get 'year'
          month: _timestamp.get 'month'
          day: _timestamp.get 'date'

  #
  # (3) Assign Reactive changes to Precision and dateParts, to recompute
  #     and set the data.date ReactiveVar.
  #
  @autorun =>
    _date =
      precision: @precisionMap[ @precision.get() ]
    switch _date.precision
      when 'years'
        _date.timestamp = moment([ @dateParts.get('year') ]).toDate()
      when 'months'
        _date.timestamp = moment([ @dateParts.get('year'), @dateParts.get('month') ]).toDate()
      when 'days'
        _date.timestamp = moment([ @dateParts.get('year'), @dateParts.get('month'), @dateParts.get('day') ]).toDate()
    Template.currentData().date.set _date

Template.partialDatePicker.helpers
  dateParts: ->
    Template.instance().dateParts.all()
  precisionGTE: (_precision) ->
    return true if Template.instance().precision.get() >= _precision
    return false

Template.partialDatePicker.events
  'click a[data-partial-date-choose]': (event, template) ->
    template.precision.set ( template.precision.get() + 1 )
  'click a[data-partial-date-delete]': (event, template) ->
    template.precision.set ( template.precision.get() - 1 )
  'change select.partial-date-picker-years': (event, template) ->
    template.dateParts.set
      year: parseInt event.currentTarget.value
  'change select.partial-date-picker-months': (event, template) ->
    template.dateParts.set
      month: parseInt event.currentTarget.value
  'change select.partial-date-picker-days': (event, template) ->
    template.dateParts.set
      day: parseInt event.currentTarget.value



###
#   Template.partialDatePickerYear
###
Template.partialDatePickerYear.rendered = ->
  @selector = @find ".partial-date-picker-years"
  @$selector = $ @selector
  #
  # (1) Initialize Material Dropdown Selector
  #
  @$selector.material_select()

Template.partialDatePickerYear.helpers
  yearOptions: ->
    [1900..2020]
  selectedYear: (_year) ->
    return true if Template.instance().data.dateParts.year is parseInt _year
    return false

Template.partialDatePickerYear.destroyed = ->
  @$selector.material_select("destroy")


###
#   Template.partialDatePickerMOnth
###
Template.partialDatePickerMonth.rendered = ->
  @selector = @find ".partial-date-picker-months"
  @$selector = $ @selector
  #
  # (1) Initialize Material Dropdown Selector
  #
  @$selector.material_select()

Template.partialDatePickerMonth.helpers
  monthOptions: ->
    [{"index":0,"month":"January"},{"index":1,"month":"February"},{"index":2,"month":"March"},{"index":3,"month":"April"},{"index":4,"month":"May"},{"index":5,"month":"June"},{"index":6,"month":"July"},{"index":7,"month":"August"},{"index":8,"month":"September"},{"index":9,"month":"October"},{"index":10,"month":"November"},{"index":11,"month":"December"}]
  selectedMonth: (_month) ->
    return true if Template.instance().data.dateParts.month is parseInt _month
    return false

Template.partialDatePickerMonth.destroyed = ->
  @$selector.material_select("destroy")


###
#   Template.partialDatePickerDay
###
Template.partialDatePickerDay.rendered = ->
  @selector = @find ".partial-date-picker-days"
  @$selector = $ @selector
  #
  # (1) Initialize Material Dropdown Selector
  #
  @$selector.material_select()

Template.partialDatePickerDay.helpers
  dayOptions: ->
    [1..31]
  selectedDay: (_day) ->
    return true if Template.instance().data.dateParts.day is parseInt _day
    return false

Template.partialDatePickerDay.destroyed = ->
  @$selector.material_select("destroy")
