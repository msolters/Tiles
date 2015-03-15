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
        return this.find({
          $or: query
          owner: Meteor.userId()
        }, _sort)
  return null
