Router.configure
  layoutTemplate: "layout"
  loadingTemplate: "loading"

Router.map ->
  @route "admin",
    path: "/"
    waitOn: ->
      return Meteor.subscribe('entries')
    data: ->
      return {
        entries: Entries.find()
      }

  @route 'entry',
    path: '/entry/:_id',
    waitOn: ->
      return Meteor.subscribe('singleEntry', this.params._id)
    data: ->
      return Entries.findOne(this.params._id)

requireAdmin = (pause) ->
  if Meteor.user()
    if _.contains(Meteor.user().profile.permissions, 'admin')
      return
    else
      @render "accessDenied"
  else
    if Meteor.loggingIn()
      @render @loadingTemplate
    else
      @render "accessDenied"
  pause()

Router.onBeforeAction "loading"
Router.onBeforeAction requireAdmin, {only: 'admin'}
Router.onBeforeAction ->
  clearErrors()
