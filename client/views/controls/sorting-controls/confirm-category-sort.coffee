###
#   Template.confirmCategorySort
###
Template.confirmCategorySort.events
  'click a[data-confirm]': (event, template) ->
    $('.tile').show()
    toast "Saving changes...", 3000, "info"
    categoryPositions = (Blaze.getData(child).category.title for child in $('#tile-container').find('.category-title'))
    pending = categoryPositions.length
    for category, pos in categoryPositions
      _query =
        title: category
      _update =
        "pos": pos
      Meteor.call "updateCategories", _query, _update, (err, resp) ->
        if err?
          pending -= 1
          toast "Problem saving new position of category #{category}!  Skipping...", 4000, "danger"
        else
          pending -= 1
          console.log pending
          if pending is 0
            toast "New arrangement committed to database successfully!", 4000, "success"
            $('.tiles').show()
            resetTiles.changed()
    template.parent().categorySortable.option "disabled", true
    template.parent().sortingCategories.set false
  'click a[data-cancel]': (event, template) ->
    resetTiles.changed()
    template.parent().categorySortable.option "disabled", true
    template.parent().sortingCategories.set false
