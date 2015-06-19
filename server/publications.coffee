Meteor.publish 'entries', ->
  unless isAdmin(@userId)
    return []

  return Entries.find()

Meteor.publish 'singleEntry', (id) ->
  check(id, String)
  return id && Entries.find(id)

Meteor.publish 'userData', ->
  if (this.userId)
    return Meteor.users.find({_id: this.userId},
                             {fields: {'services.sandstorm.permissions': 1}});
  else
    this.ready()


calcTotal = ->
  total = 0
  Entries.find().forEach (row) ->
    total += row.donation
  return total

Meteor.startup ->
  total = TotalDonation.findOne()
  if !total
    TotalDonation.insert({total: 0})
  else
    TotalDonation.update({_id: total._id}, {$set: {total: 0}})

  # we don't need an added cb, since changed is called on adds
  @Entries.find().observe
    changed: (doc, docBefore) ->
      total = TotalDonation.findOne()
      previous = docBefore.donation || 0
      if doc.donation
        TotalDonation.update({_id: total._id}, {$inc: {total: doc.donation - previous}})

Meteor.publish 'totalDonation', ->
  TotalDonation.find()
