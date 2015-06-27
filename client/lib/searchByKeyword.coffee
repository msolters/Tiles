Meteor.Collection.prototype.searchByKeyword = (options) ->
  if options
    if options.keywords
      if options.keywords.length >= 3
        check options.keywords, String
        query = []
        # splitting this array by spaces means any one keyword will match!!!  this can get ugly...
        keywordArray = [options.keywords]#.split ' '
        regexKeywords = ( new RegExp(keyword, 'i') for keyword in keywordArray)
        for field in options.fields
          _q = {}
          _q[field] =
            $in: regexKeywords
          query.push _q

        finalQuery =
          $or: query
        if options.selector?
          finalQuery[field] = val for field, val of options.selector
        return this.find(finalQuery, _sort)
  return null
