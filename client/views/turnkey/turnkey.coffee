#
#     Template.establishURL
#
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
  'submit form#verify-url': ->
    url = $("input#user-url").val()
    if url.length is 0
      toast "You must choose a URL to proceed!  Don't make this harder than it has to be.", 5000, "danger"
      return false
    else
      if RegExp(/[\\/]/).test url is true
        toast "Sorry, no slashes!", 6500, "danger"
        return false
      url_encoded = encodeURIComponent url
      if url isnt url_encoded
        toast "People would have to type http://#{window.location.hostname}/#{url_encoded} to get to your page!!  Are you out of your magnificient mind?  Pick a better URL!  (Avoid spaces, slashes and weird characters.)", 6500, "danger"
        return false
      else
        url = url_encoded
        Meteor.call "verifyURL", url, (error, response) ->
          if error?
            toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
            return false
          else
            if response is true
              Meteor.call "updateUser", {"profile.public_url": url}, (error, response) ->
                if error?
                  console.log error
                  toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
                  return false
                else
                  if response is true
                    Router.go "/#{url}"
                  return false
            else
              toast "Sorry, that URL is already taken!  Please try to be more creative.  For fuck's sake.", 5000, "danger"
    return false



#
#     Template.register
#
Template.register.created = ->
    @waiters = {}

Template.register.rendered = ->
  toast "Welcome to TilesJS!", 20000, "success"
  setTimeout ->
      toast "Create an account to get started.", 20000, "info"
    , 900

Template.register.events
  'submit form#register-form': (event, template) ->
    name = template.find('input#user-profile-name').value
    email = template.find('input#user-email').value
    password = template.find('input#user-password').value
    passwordConfirm = template.find('input#user-password-confirm').value
    if name.length is 0
      toast "Please enter a name!  Seriously, this is going to be your website.  That's your name up there.  Don't you even care?", 5000, "danger"
      return false
    if email.length is 0
      toast "Please enter a valid e-mail address!", 5000, "danger"
      return false
    if password.length <= 6
      toast "Password must be 6 characters or more.", 5000, "danger"
      return false
    else
      if password isnt passwordConfirm
        toast "Those passwords don't match!", 5000, "danger"
        return false

    Meteor.call "createNewUser", email, password, name, (error, response) ->
      if error?
        console.log error
        toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
        return false
      else
        if response.success is true
          Meteor.loginWithPassword email, password
          template.waiters.vanilla.stop() if template.waiters.vanilla?
          template.waiters.vanilla = Deps.autorun =>
            if Meteor.userId()?
              $(".toast").remove()
              Router.go "/setup"
          return false
          ###
          toast "Nice work, bone daddy!  Can I call you #{name.split(' ')[0]}?", 15000, "success"
          setTimeout =>
            toast "(Simply click or swipe these messages to dismiss)", 15000, "info"
          , 1500
          ###
        else
          toast response.msg, 6500, "danger"
          return false
    return false


#
#   Template.login
#
Template.loginForm.events
  'submit form#login-form': (event, template) ->
    email = template.find('input#user-email').value
    password = template.find('input#user-password').value
    if email.length is 0
      toast "Please enter a valid e-mail address!", 5000, "danger"
      return false
    if password.length is 0
      toast "Please enter a valid password!", 5000, "danger"
      return false
    Meteor.loginWithPassword email, password, (error) ->
      if error
        toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
      else
        given_name = "Asshole"
        if Meteor.user().profile?
          if Meteor.user().profile.name?
            given_name = Meteor.user().profile.name.split(' ')[0] if Meteor.user().profile.name.split(' ')[0].length > 0
        toast "Welcome back, #{given_name}!", 7000, "success"
        if given_name is "Asshole"
          toast "Hey you should probably fill in your name (top left).", 7000, "info"
        $(template.find('#login-modal')).closeModal()
    return false


#
#     Template.socialLogin
#
Template.socialLogin.created = ->
  @data.waiters = {}

Template.socialLogin.events
  'click button#facebook-account': (event, template) ->
    Meteor.loginWithFacebook {}, (err) ->
      if err?
        if err.reason?
          err_msg = err.reason
        else
          err_msg = err
        toast "#{err_msg}", 4000, "danger"
        return
      else
        #Router.go '/'
        $('#login-modal').closeModal()

  'click button#google-account': (event, template) ->
    Meteor.loginWithGoogle {}, (err) ->
      if err?
        if err.reason?
          err_msg = err.reason
        else
          err_msg = err
        toast "#{err_msg}", 4000, "danger"
        return
      else
        #Router.go '/'
        $('#login-modal').closeModal()
