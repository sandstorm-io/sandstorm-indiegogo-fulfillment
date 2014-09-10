#!node_modules/.bin/coffee

fs = require('fs')
csv = require("csv")
_ = require("underscore")
url = require("url")
path = require("path")
templatesDir = path.resolve(__dirname, "templates")
emailTemplates = require("email-templates")
nodemailer = require("nodemailer")
smtpTransport = require('nodemailer-smtp-transport')

usage = ->
  console.log '''usage: mailer.coffee CSV_FILE GRAIN_URL SMTP_PATH

Script for mailing indiegogo fulfillment messages to users

positional arguments:
  CSV_FILE        A csv file downloaded from the webapp
  GRAIN_URL       The URL to the webapp
  SMTP_PATH       An SMTP url of the form smtp://USER:PASSWORD@SERVER:PORT
'''

if _.contains process.argv, '-h'
  usage()
  process.exit 0

if process.argv.length != 5
  usage()
  process.exit 1

csv_file = process.argv[2]
grain_url = process.argv[3]
smtp_path = process.argv[4]

emailTemplates templatesDir, (err, template) ->
  if err
    console.log err
  else
    parsed_smtp = url.parse smtp_path
    user = parsed_smtp.auth.split(':')[0]
    pass = parsed_smtp.auth.split(':')[1]

    # Prepare nodemailer transport object
    transportBatch = nodemailer.createTransport smtpTransport(
      host: parsed_smtp.hostname
      port: parsed_smtp.port
      auth:
        user: user
        pass: pass
    )

    # An example users object
    users = [
      {
        email: "test1@jparyani.com"
        name:
          first: "Pappa"
          last: "Pizza"
      }
      {
        email: "test2@jparyani.com"
        name:
          first: "Mister"
          last: "Geppetto"
      }
    ]

    # Custom function for sending emails outside the loop
    Render = (locals) ->
      @locals = locals
      @send = (err, html, text) ->
        if err
          console.log err
        else
          transportBatch.sendMail
            from: "Sandstorm Fulfillment <indiegogo-fulfillment@sandstorm.io>"
            to: [locals.email]
            subject: "Sandstorm Indiegogo Fulfillment"
            html: html
            text: text
          , (err, responseStatus) ->
            if err
              console.log err
            else
              console.log responseStatus
            return

        return

      @batch = (batch) ->
        batch @locals, templatesDir, @send
        return

      return

    csv_input = fs.createReadStream(csv_file)
    send_mail = (batch) -> (record) ->
      if not record.lastUpdated
        render = new Render(record)
        render.batch batch

    # Load the template and send the emails
    template "fulfillment", true, (err, batch) ->
      csv_input.pipe(csv.parse({columns: true})).
                pipe(csv.transform(send_mail(batch)))
