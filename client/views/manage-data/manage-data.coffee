###
#   Template.manageData
###
Template.manageData.rendered = ->
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
        base64ToBlob = (base64String) ->
          byteChars = atob base64String
          byteNumbers = new Array byteChars.length
          i = 0
          while i < byteChars.length
            byteNumbers[i] = byteChars.charCodeAt i
            i++
          byteArray = new Uint8Array byteNumbers
          return blob = new Blob [byteArray],
            type: 'zip'

        blob = base64ToBlob resp
        saveAs blob, 'export.zip'
