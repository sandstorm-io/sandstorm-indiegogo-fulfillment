Template.entry.rendered = ->
  if not @data
    throwError("Couldn't find your info. Please make sure your URL is correct.")
  $("[name='email']").attr("readonly", "readonly")
  if !@data.donation
    $("[name='donation']").val(@data.maxDonation)

Template.entry.created = ->
  Session.set 'isUpdated', false
  window.parent.postMessage({'setPath': location.pathname}, '*')

Template.entry.isUpdated = ->
  Session.get 'isUpdated'

Template.entry.submitText = ->
  if @lastUpdated
    'Update'
  else
    'Confirm'

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
