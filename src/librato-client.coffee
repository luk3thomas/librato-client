# LibratoClient proxies the instrumentation methods through to
# Instruments and sends data to the endpoint on completion.

{ compact, combineArray } = require('./utils.coffee')
Sources = require('./sources.coffee')
Instruments = require('./instruments.coffee')

class LibratoClient
  constructor: (opts={}) ->
    @endpoint        = opts.endpoint   ? '/'
    @prefix          = opts.prefix     ? null
    @headers         = opts.headers    ? {}
    @source          = opts.source     ? 'page'

    @sources = new Sources()

  # Instrumentation methods
  increment: -> Instruments.increment.apply @, combineArray([@send], arguments)
  measure:   -> Instruments.measure.apply   @, combineArray([@send], arguments)
  timing:    -> Instruments.timing.apply    @, combineArray([@send], arguments)

  # Methods for sending data
  prepare: (data) ->
    data.metric = compact([@prefix, data.metric]).join '.'
    data.source = @sources.createSource(@source, data.source)
    data

  send: (data) ->
    json = JSON.stringify(@prepare(data))
    xhr = @xhr()
    xhr.open('POST', @endpoint, true)
    xhr.setRequestHeader('Content-Type', 'application/json')
    xhr.setRequestHeader(header, value) for header, value of @headers
    xhr.send(json)
    @

  xhr: ->
    new XMLHttpRequest()

  # creates a new client with the current settings and any new custom options.
  # Helpful if you want to change the source template for a particular
  # instrumentation, e.g. error exceptions
  fork: (opts={}) ->
    settings    = { @endpoint, @prefix, @headers, @source }
    settings[k] = v for k, v of opts
    new LibratoClient(settings)

  # Easily switches the source template tag
  # e.g. trackByBrowser = client.withSource('browser.version')
  # e.g. client.withSource('browser.version').increment 'foo'
  withSource: (source) ->
    @fork source: source

  # Adds data for the callback that creates a source tag.
  sourceArg: ->
    @sources.addTagArg.apply(@sources, arguments)

module.exports = LibratoClient
