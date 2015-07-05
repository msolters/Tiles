Meteor.publish 'Tiles', (slug={}) ->
  return Tiles.find( slug )
Meteor.publish 'Categories', (slug={}) ->
  return Categories.find( slug )
Meteor.publish 'Users', (slug={}) ->
  return Meteor.users.find( slug, {fields: {profile: 1}} )
