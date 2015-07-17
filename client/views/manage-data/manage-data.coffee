###
#   Template.manageData
###
Template.manageData.rendered = ->
  #
  # (1) Active Tabs
  #
  @tabs = $ "#manage-data-tabs"
  @tabs.tabs()
  Meteor.setTimeout =>
    @tabs.tabs 'select_tab', 'backup-tools'
  , 300

Template.manageData.events
  'change input[data-restore]': (event, template) ->
    readFile = (f, onLoadCallback) ->
      reader = new FileReader()
      reader.onload = (e) ->
        contents = e.target.result
        onLoadCallback contents
      reader.readAsText f
    f = $(event.currentTarget)[0].files[0]
    readFile f, (content) ->
      Meteor.call 'importData', content, (err, resp) ->
        if err?
          Materialize.toast "An error occurred while restoring your data: #{err}", 4000, "red"
        else
          Materialize.toast "Data successfully restored!", 4500, "green"
          MaterializeModal.close()

  'click button[data-backup]': ->
    Meteor.call 'exportData', (err, resp) ->
      if err?
        Materialize.toast "An error occurred while exporting your data: #{err}", 4500, "danger"
      else
        blob = new Blob [resp],
          type: 'text/xml'
        now = moment().format "MM-DD-YYYY-hh-mma"
        saveAs blob, "tiles-backup-#{Meteor.user().profile.public_url}-#{now}.xml"
        Materialize.toast "Data successfully exported to .xml!", 4500, "green"
