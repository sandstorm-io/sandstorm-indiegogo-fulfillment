Meteor.publish 'entries', ->
  unless isAdmin(@userId)
    return []

  return Entries.find()

Meteor.publish 'singleEntry', (id) ->
  return id && Entries.find(id)

Meteor.publish 'userData', ->
  if (this.userId)
    return Meteor.users.find({_id: this.userId},
                             {fields: {'services.sandstorm.permissions': 1}});
  else
    this.ready()
