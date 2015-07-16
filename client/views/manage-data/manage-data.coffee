###
#   Template.manageData
###
Template.manageData.events
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
