#
#     Template.register
#
Template.register.created = ->
  @waiters = {} # used to store interval timer handles

Template.register.rendered = ->
  if !Meteor.user()
    toast "Welcome to TilesJS!", 20000, "success"
    setTimeout ->
        toast "Create an account to get started.", 20000, "info"
      , 900
  #@autorun =>
  #  FlowRouter.go '/' if Meteor.userId()? # move the user on if they have an account!

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
              FlowRouter.go "/setup"
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
Template.login.created = ->
  @autorun ->  # kicks non-logged in users out
    ifLoggedIn ->
      if Meteor.user().profile.public_url?
        # If the logged-in user has setup a URL, take them there:
        FlowRouter.go "/#{Meteor.user().profile.public_url}"
      else
        # If the logged-in user has no URL, take them to the setup page:
        FlowRouter.go "/setup"

#
#   Template.loginForm
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
        $('#login-modal').closeModal() # in case this is from the login modal

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
        $('#login-modal').closeModal()  # in case this is from the login modal
