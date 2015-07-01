@Entries = new Meteor.Collection 'entries'
# Entries of Indiegogo users

@Entries.attachSchema(new SimpleSchema(
  email:
    type: String,
    label: "Email",
  ,
  name:
    type: String,
    label: "Name for Roundcube Next credits",
    optional: true
  ,
  maxDonation:
    type: Number,
    label: "Maximum possible donation"
  ,
  donation:
    type: Number,
    label: "Amount to contribute ($)",
    optional: true
  ,
  lastUpdated:
    type: Date,
    label: "Last updated",
    optional: true
  ,
  link:
    type: String,
    label: "Link to entry",
    optional: true
  ,
  unsubscribed:
    type: Boolean,
    label: "Unsubscribed",
    optional: true
  ,
))

@Entries.allow
  update: (userId, doc) ->
    return true

@Entries.deny
  update: (userId, doc, fieldNames, modifier) ->
    modifier.$set.lastUpdated = Date.now()

    if fieldNames.length > 0
      throw new Meteor.Error(403, "This form has expired.")

    if _.contains(fieldNames, "donation")
      if modifier["$set"].donation > doc.maxDonation
        throw new Meteor.Error(403, "You entered a donation amount greater than your maximum possible $#{doc.maxDonation}.")
      if modifier["$set"].donation < 0
        throw new Meteor.Error(403, "You entered a donation less than 0.")

    return _.without(fieldNames, 'name', 'donation', 'unsubscribed').length > 0

@TotalDonation = new Meteor.Collection 'totalDonation'
