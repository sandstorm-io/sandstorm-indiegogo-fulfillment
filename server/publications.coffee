Meteor.publish 'entries', ->
  unless isAdmin(@userId)
    return null

  return Entries.find()

Meteor.publish 'singleEntry', (id) ->
  return id && Entries.find(id)
