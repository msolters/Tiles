# Only server can create a user!
Accounts.config
  forbidClientAccountCreation: true

###
#   Only users with no matching e-mails in the user database can be created
#   at this time.
###
Accounts.validateNewUser (user) ->
  #
  # (1) Validate user's email
  #
  email =
    $in: []
  if user.emails?
    for e in user.emails
      email.$in.push e.address
  if user.services?
    for serviceName, service of user.services
      email.$in.push service.email if service.email?
  console.log email
  query =
    $or: []
  _.each Accounts.oauth.serviceNames(), (name) ->
      q = {}
      q["services.#{name}.email"] = email;
      query.$or.push(q);
      q = {};
      q["services.#{name}.emailAddress"] = email
      query.$or.push q
  query.$or.push
    'emails.address': email
  console.log query
  if Meteor.users.findOne(query)
    throw new Meteor.Error 500, 'Could not create new user; e-mail already taken.', 'E-mail already taken.'

  #
  # (2) Validate user's URL
  #
  if user.profile.public_url?
    verifyURL = Meteor.call "verifyURL", user.profile.public_url
    if verifyURL.success
      return true
    else
      throw new Meteor.Error 500, verifyURL.msg, verifyURL.msg
  else
    return true

# First remove any services that may have been auto/already configured:
ServiceConfiguration.configurations.remove
  service:
    $in: ["facebook", "twitter", "google"]

ServiceConfiguration.configurations.insert
  service: "google"
  clientId: "204767897565-0htfv8rfc4njfhnkqbm3c3dsr4f3o9ra.apps.googleusercontent.com"
  secret: "_s3YqyBq4yDW2aIYvVvb0VaZ"
ServiceConfiguration.configurations.insert
  service: "facebook"
  appId: "363206583870762"
  secret: "5303f40d3f93963a3636035a2eb1a36b"
