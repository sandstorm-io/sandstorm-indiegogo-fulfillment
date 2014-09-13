@Entries = new Meteor.Collection 'entries'
# Entries of Indiegogo users

@Entries.attachSchema(new SimpleSchema(
  email:
    type: String,
    label: "Email",
  ,
  name:
    type: String,
    label: "Name for credits",
    optional: true
  ,
  address:
    type: String,
    label: "Shipping address",
    optional: true
  ,
  shirtSize:
    type: String,
    label: "Shirt size",
    optional: true
  ,
  isShippingRelevant:
    type: Boolean,
    label: "Is shipping address needed?"
  ,
  isSizeRelevant:
    type: Boolean,
    label: "Is shirt size needed?"
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
))

@Entries.allow
  update: (userId, doc) ->
    return true

@Entries.deny
  update: (userId, doc, fieldNames, modifier) ->
    modifier.$set.lastUpdated = Date.now()

    return _.without(fieldNames, 'name', 'address', 'shirtSize').length > 0
