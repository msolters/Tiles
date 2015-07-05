###
#   Template.confirmTileSort
###
Template.confirmTileSort.events
  'click a[data-confirm]': (event, template) ->
    toast "Saving changes...", 3000, "info"
    tilePositions = {}
    currentCat = null
    for child in $('#tile-container').children()
      $child = $ child
      if $child.is(".category-title")
        currentCat = Blaze.getData(child).category.title
        tilePositions[currentCat] = []
      if $child.is(".tile")
        tilePositions[currentCat].push Blaze.getData(child).tile._id

    pending = 0
    for cat, tileList of tilePositions
      pending += tileList.length

    for cat, tileList of tilePositions
      for _id, i in tileList
        _tile =
          category: cat
          pos: i
        Meteor.call "saveTile", _tile, _id, (err, resp) ->
          if err?
            pending -= 1
            toast "Problem saving new position of tile #{_id}!  Skipping...", 4000, "danger"
          else
            pending -= 1
            console.log pending
            if pending is 0
              toast "New arrangement committed to database successfully!", 4000, "success"
    template.data.sortingTiles.set false
  'click a[data-cancel]': (event, template) ->
    template.data.sortingTiles.set false
