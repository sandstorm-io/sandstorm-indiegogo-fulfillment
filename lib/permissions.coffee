# check that the userId specified owns the documents
@ownsDocument = (userId, doc) ->
  doc and doc.userId is userId

@isAdmin = (userId) ->
  user = Meteor.users.findOne userId
  user and _.contains(user.profile.permissions, 'admin')
