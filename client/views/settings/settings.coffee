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
    return true if Template.instance().urlState.get() is urlState
    return false

Template.settingsURL.events
  'input input#user-public-url': (event, template) ->
    template.urlState.set "pending"
    url = event.currentTarget.value
    Meteor.call 'verifyURL', url, (err, resp) ->
      if err
        Materialize.toast err, 5000, "red"
        template.urlState.set "invalid"
      else
        if resp.success
          template.urlState.set "valid"
        else
          Materialize.toast resp.msg, 5000, "red"
          template.urlState.set "invalid"
  'submit form#update-url': (event, template) ->
    url = template.find("input#user-public-url").value
    Meteor.call 'verifyURL', url, (err, resp) ->
      if err
        Materialize.toast err, 5000, "red"
        template.urlState.set "invalid"
      else
        if resp.success
          Meteor.call "updateUser", {"profile.public_url": url}, (error, response) ->
            if error?
              toast "Error:  #{error.reason}", 5000, "danger"
            else
              if response is true
                FlowRouter.redirect "/#{url}"
                MaterializeModal.close()
        else
          Materialize.toast resp.msg, 5000, "red"
          template.urlState.set "invalid"
    return false
