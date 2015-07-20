###
#      Template.settings
###
Template.settings.rendered = ->
  #
  # (1) Active Tabs
  #
  @tabs = $ "#settings-tabs"
  @tabs.tabs()
  Meteor.setTimeout =>
    @tabs.tabs 'select_tab', 'profile-settings'
  , 300

Template.settings.events
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
        Materialize.toast "Data successfully exported to .xml!", 4500, "green"
        saveAs blob, "tiles-backup-#{Meteor.user().profile.public_url}-#{now}.xml"


###
#   Template.settingsURL
###
Template.settingsURL.created = ->
  @urlState = new ReactiveVar 0
  @urlState.set "valid"

Template.settingsURL.helpers
  urlIs: (urlState) ->
    return true if Template.currentInstance().urlState.get() is urlState
    return false

Template.settingsURL.events
  'keydown input#user-public-url': (event, template) ->
