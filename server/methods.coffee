isTesting = Meteor.settings && Meteor.settings.isTesting

csv_parse = Meteor._wrapAsync(csv.parse)
csv_stringify = Meteor._wrapAsync(csv.stringify)

if isTesting
  console.log 'Adding login functions'
  Meteor.methods
    loginTest: ->
      # login from client with Meteor.call('loginTest', function(err, res) {  Meteor.loginWithToken(res, function() {}); })
      Meteor.users.remove({})
      login = Accounts.updateOrCreateUserFromExternalService("sandstorm",
        id: 0
      ,
        profile:
          name: 'Test Admin'
          permissions: ['admin']
      )
      console.log login
      token = Accounts._generateStampedLoginToken()
      Accounts._insertLoginToken login.userId, token
      return token.token


Meteor.methods
  uploadCsv: (data) ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    parsed = csv_parse data, {columns: true}
    parsed.forEach (row) ->
      row.lastUpdated = null
      row.isShippingRelevant = if row.isShippingRelevant == 'true' then true else false
      row.isSizeRelevant = if row.isSizeRelevant == 'true' then true else false
      id = Entries.insert row
      Entries.update {_id: id}, {'$set': {'link': "/entry/#{id}"}}
    return

  downloadCsv: (data) ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    entries = Entries.find().fetch()
    entries = _.map entries, (row) ->
      return _.omit(row, '_id')

    return csv_stringify entries, {header: true}

  clearEntries: ->
    unless isAdmin(Meteor.userId())
      throw new Meteor.Error(403, "Unauthorized", "Must be admin")

    Entries.remove({})
    return
