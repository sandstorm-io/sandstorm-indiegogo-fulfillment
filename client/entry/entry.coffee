Template.entry.rendered = ->
  if not @data
    throwError("Couldn't find your info. Please make sure your URL is correct.")
  $("input").attr("readonly", "readonly")
  $("button").addClass("hide")

Template.entry.created = ->
  Session.set 'isUpdated', false
  window.parent.postMessage({'setPath': location.pathname}, '*')

Template.entry.isUpdated = ->
  Session.get 'isUpdated'

Template.entry.unsubscribed = ->
  Session.get 'unsubscribed'

Template.entry.submitText = ->
  if @lastUpdated
    'Update'
  else
    'Confirm'

Template.entry.totalDonation = ->
  TotalDonation.findOne().total

AutoForm.hooks
  updateEntryForm:
    before:
      update: (docId, modifier, template) ->
        delete modifier.$set['email']
        return modifier

    onSuccess: ->
      Session.set 'isUpdated', false
      Session.set 'isUpdated', true

    onError: (_, err) ->
      throwError(err)
