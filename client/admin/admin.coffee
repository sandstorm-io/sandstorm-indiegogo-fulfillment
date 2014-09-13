download = (filename, text) ->
  pom = document.createElement('a')
  pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text))
  pom.setAttribute('download', filename)
  pom.click()

reconnectHandler = ->
  location.reload()

Template.admin.events
  "click #uploadCsv": (event) ->
    input = document.createElement("input")
    input.type = "file"
    input.style = "display: none"
    input.addEventListener "change", (e) ->
      # TODO: make sure only 1 file is uploaded
      file = e.currentTarget.files[0]
      reader = new FileReader()

      reader.onload = (e) ->
        Meteor.call('uploadCsv', reader.result, (err) ->
          if err
            throwError(err)
          Meteor.disconnect()
          $('#csvLoading').css('display', 'block')
          Meteor.setTimeout reconnectHandler, 5000
        )

      reader.readAsText(file)

    input.click()
    return

  "click #downloadCsv": (event) ->
    Meteor.call 'downloadCsv', (err, data) ->
      if err
        throwError(err)
        return
      download('data.csv', data)

Template.admin.tableSettings = ->
  fields = [
    'email',
    'name',
    'address',
    'shirtSize',
    'isShippingRelevant',
    'isSizeRelevant'
  ]

  schema = Entries.simpleSchema()._schema
  fields = _.map fields, (row) ->
    return {
      key: row,
      label: schema[row].label
    }

  fields.push
    key: 'lastUpdated',
    label: schema.lastUpdated.label,
    fn: (value, object) ->
      if value
        new Date(value)

  fields.push
    key: 'link',
    label: schema.link.label,
    fn: (value, object) ->
      new Spacebars.SafeString("<a href=#{value}>#{value}</a>")

  return {
    rowsPerPage: 100,
    fields: fields
  }
