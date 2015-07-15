###
#   Template.tileBigEdit
###

Template.tileBigEdit.rendered = ->
  @contentEdit = $ @find "#tile-edit-content"
  @contentEdit.summernote()
