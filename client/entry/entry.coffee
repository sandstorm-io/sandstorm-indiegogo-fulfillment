Template.entry.rendered = ->
  if not @data
    throwError("Couldn't find your info. Please make sure your URL is correct.")
  $("[name='email']").attr("readonly", "readonly")
  $("option[value='#{@data.shirtSize || "Men's Medium"}']").prop('selected', true)

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

Template.entry.isConfirmed = ->
  if @lastUpdated
    true
  else
    false

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
