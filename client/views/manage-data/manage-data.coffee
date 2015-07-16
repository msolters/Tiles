###
#   Template.manageData
###
Template.manageData.rendered = ->
  #
  # (1) Active Tabs
  #
  $("#manage-data-tabs").tabs()
  #
  # (2) Active File Input (for Import)
  #
  $('.file-field').each ->
    path_input = $(this).find 'input.file-path'
    $(this).find('input[type="file"]').change ->
      files = $(this)[0].files
      file_names = (file.name for file in files)
      path_input.val file_names.join(", ")
      path_input.trigger('change')

Template.manageData.events
  'click button[data-import]': ->
    readFile = (f, onLoadCallback) ->
      reader = new FileReader()
      reader.onload = (e) ->
        contents = e.target.result
        onLoadCallback contents
      reader.readAsText f
    f = $('input[data-import-file]')[0].files[0]
    readFile f, (content) ->
      Meteor.call 'importData', content, (err, resp) ->
        console.log resp

  'click button[data-export]': ->
    Meteor.call 'exportData', (err, resp) ->
      if err
        Materialize.toast "An error occurred while exporting your data: #{err}", 4500, "danger"
      else
        blob = new Blob [resp],
          type: 'text/xml'
        now = moment().format "MM-DD-YYYY-hh-mma"
        saveAs blob, "tiles-backup-#{Meteor.user().profile.public_url}-#{now}.xml"
