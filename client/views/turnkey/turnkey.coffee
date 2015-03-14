#
#     Template.establishURL
#
Template.establishURL.rendered = ->
  $("input#user-url").focus()

Template.establishURL.helpers
  'hostname': -> window.location.hostname

Template.establishURL.events
  'focus input#user-url': (event, template) ->
    if !Session.get("urlExplained")?
      toast "This will be the URL you can access your page from, i.e. http://#{window.location.hostname}/<b>mypagehere</b>", 3500, "info"
      Session.set("urlExplained", true)
  'input input#user-url': (event, template) ->
    clearTimeout template.urlTimer if template.urlTimer?
    _url = event.currentTarget.value
    template.urlTimer = setTimeout =>
      toast "Your URL will be http://#{window.location.hostname}/#{_url}", 3000
    , 400
  'submit form#verify-url': ->
    return unless @forceUpdate is true
    url = $("input#user-url").val()
    if url.length is 0
      toast "Please enter a URL!", 5000, "danger"
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
        if error
          toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
          return false
        else
          if response is true
            Meteor.call "updateUser", {"profile.public_url": url}, (error, response) ->
              if error?
                console.log error
                toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
              else
                if response.success is true
                  Router.go "/#{url}"
    return false



#
#     Template.register
#
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
    url = template.find('input#user-url').value.toLowerCase()
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
    if url.length is 0
      toast "Please enter a profile URL!", 5000, "danger"
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
      if error
        toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
      else
        if response is true
          Meteor.call "createNewUser", email, password, name, url, (error, response) ->
            if error?
              console.log error
              toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
            else
              if response.success is true
                Meteor.loginWithPassword email, password
                $(".toast").remove()
                Deps.autorun =>
                  if Meteor.userId()?
                    Router.go "/#{url}"
                toast "Nice work, bone daddy!  Can I call you #{name.split(' ')[0]}?", 15000, "success"
                setTimeout =>
                  toast "(Simply click or swipe these messages to dismiss)", 15000, "info"
                , 1500
              else
                toast response.msg, 6500, "danger"
        else
          toast "That URL is already taken!  Please choose another.", 6500, "danger"
    return false


#
#   Template.login
#
Template.login.events
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
    console.log template
    switch @action
      when "register"
        url = $("#user-url").val()
        if url.length is 0
          toast "Please enter a profile URL above!", 5000, "danger"
          $("#user-url").focus()
          return false
        else
          url_encoded = encodeURIComponent url
          if url isnt url_encoded
            toast "People would have to type http://#{window.location.hostname}/#{url_encoded} to get to your page!!  Are you out of your magnificient mind?  Pick a better URL!  (Avoid spaces, slashes and weird characters.)", 6500, "danger"
            return false
          else
            url = url_encoded
        Meteor.call "verifyURL", url, (error, response) ->
          if error
            toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
          else
            if response is true
              Meteor.loginWithFacebook()
              waiter.stop() for waiter in template.data.waiters
              template.data.waiters.facebook = Deps.autorun =>
                if Meteor.userId()?
                  Meteor.call "updateUser", {"profile.public_url": url}, (err, response) ->
                    if !err?
                      Router.go "/#{url}"
                      toast "Nice work, bone daddy!  Can I call you #{Meteor.user().profile.name.split(' ')[0]}?", 15000, "success"
                      setTimeout =>
                        toast "(Simply click or swipe these messages to dismiss)", 15000, "info"
                      , 1500
            else
              toast "That URL is already taken!  Please choose another.", 6500, "danger"
      when "login"
        Meteor.loginWithFacebook {}, (err) ->
          if err?
            toast "#{err.reason}", 4000, "danger"
            if err.error is 505
              $('#login-modal').closeModal()
              Router.go 'Register'
        waiter.stop() for waiter in template.data.waiters
        template.data.waiters.facebook = Deps.autorun =>
          if Meteor.userId()?
            given_name = "Asshole"
            if Meteor.user().profile?
              if Meteor.user().profile.name?
                given_name = Meteor.user().profile.name.split(' ')[0] if Meteor.user().profile.name.split(' ')[0].length > 0
            toast "Welcome back, #{given_name}!", 7000, "success"
            if given_name is "Asshole"
              toast "Hey you should probably fill in your name (top left).", 7000, "info"
            $('#login-modal').closeModal()
  'click button#google-account': (event, template) ->
    switch @action
      when "register"
        url = $("#user-url").val()
        if url.length is 0
          toast "Please enter a profile URL above!", 5000, "danger"
          $("#user-url").focus()
          return false
        else
          url_encoded = encodeURIComponent url
          if url isnt url_encoded
            toast "People would have to type http://#{window.location.hostname}/#{url_encoded} to get to your page!!  Are you out of your magnificient mind?  Pick a better URL!  (Avoid spaces, slashes and weird characters.)", 6500, "danger"
            return false
          else
            url = url_encoded
        Meteor.call "verifyURL", url, (error, response) ->
          if error
            toast "Ya fucked up now!  #{error.reason}", 5000, "danger"
          else
            if response is true
              Meteor.loginWithGoogle()
              waiter.stop() for waiter in template.data.waiters
              template.data.waiters.google = Deps.autorun =>
                if Meteor.userId()?
                  Meteor.call "updateUser", {"profile.public_url": url}, (err, response) ->
                    if !err?
                      Router.go "/#{url}"
                      toast "Nice work, bone daddy!  Can I call you #{Meteor.user().profile.name.split(' ')[0]}?", 15000, "success"
                      setTimeout =>
                        toast "(Simply click or swipe these messages to dismiss)", 15000, "info"
                      , 1500
            else
              toast "That URL is already taken!  Please choose another.", 6500, "danger"
      when "login"
        Meteor.loginWithGoogle {}, (err) ->
          if err?
            toast "#{err.reason}", 4000, "danger"
            if err.error is 505
              $('#login-modal').closeModal()
              Router.go 'Register'
        waiter.stop() for waiter in template.data.waiters
        template.data.waiters.google = Deps.autorun =>
          if Meteor.userId()?
            given_name = "Asshole"
            if Meteor.user().profile?
              if Meteor.user().profile.name?
                given_name = Meteor.user().profile.name.split(' ')[0] if Meteor.user().profile.name.split(' ')[0].length > 0
            toast "Welcome back, #{given_name}!", 7000, "success"
            if given_name is "Asshole"
              toast "Hey you should probably fill in your name (top left).", 7000, "info"
            $('#login-modal').closeModal()
