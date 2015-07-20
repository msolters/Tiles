###
#   Template.establishURL
###
Template.establishURL.created = ->
  @autorun =>
    ifLoggedOut ->
      FlowRouter.go '/'

Template.establishURL.rendered = ->
  $("input#user-url").focus()

Template.establishURL.helpers
  'hostname': -> window.location.hostname

Template.establishURL.events
  'input input#user-url': (event, template) ->
    clearTimeout template.urlTimer if template.urlTimer?
    return unless event.currentTarget.value.length > 0
    template.urlTimer = setTimeout =>
      _url = event.currentTarget.value
      url_encoded = encodeURIComponent _url
      if _url isnt url_encoded
        toast "People would have to type http://#{window.location.hostname}/#{url_encoded} to get to your page!!  Are you out of your magnificient mind?  Pick a better URL!  (Avoid spaces, slashes and weird characters.)", 6500, "danger"
      else
        toast "Your URL will be: http://#{window.location.hostname}/#{_url}", 3000
    , 400
  'click a[data-cancel]': (event, template) ->
    FlowRouter.go "/#{Meteor.user().profile.public_url}"
  'submit form#verify-url, click a[data-confirm]': ->
    url = $("input#user-url").val()
    if url.length is 0
      toast "You must choose a URL to proceed!  Don't make this harder than it has to be.", 5000, "danger"
      return false
    else
      Meteor.call "verifyURL", url, (error, response) ->
        if error?
          toast "Error:  #{error.reason}", 5000, "danger"
          return false
        else
          if response.success
            Meteor.call "updateUser", {"profile.public_url": url}, (error, response) ->
              if error?
                console.log error
                toast "Error:  #{error.reason}", 5000, "danger"
                return false
              else
                if response is true
                  FlowRouter.redirect "/#{url}"
                return false
          else
            toast response.msg, 5000, "danger"
    return false
