{ post } = require('./xhr.coffee')
{ compact, combineArray, extend } = require('./utils.coffee')
Sources = require('./sources.coffee')
Instruments = require('./instruments.coffee')

class LibratoClient
  constructor: (opts={}) ->
    { endpoint = '/'
    , prefix   = null
    , headers  = {}
    , metric   = null
    , source   = null } = opts

    @settings = { endpoint, prefix, headers, metric, source }

    @sources = new Sources()

  # Methods for sending data
  prepare: (data) ->
    { prefix, metric, source } = @settings
    data.metric = compact([prefix, metric, data.metric]).join '.'
    data.source = @sources.createSource(source, data.source)
    data

  send: (data) ->
    { endpoint, headers } = @settings
    post({ endpoint
         , data: JSON.stringify(@prepare(data))
         , headers: extend({'Content-Type': 'application/json'}, headers) })
    @

  # Fork methods for updating the client's settings
  fork: (opts={}) ->
    new LibratoClient(extend(@settings, opts))

  source: (source)     -> @fork { source }
  metric: (metric)     -> @fork { metric }
  prefix: (prefix)     -> @fork { prefix }
  headers: (headers)   -> @fork { headers }
  endpoint: (endpoint) -> @fork { endpoint }


  # Instrumentation methods
  increment: -> Instruments.increment.apply @, combineArray([@send], arguments)
  measure:   -> Instruments.measure.apply   @, combineArray([@send], arguments)
  timing:    -> Instruments.timing.apply    @, combineArray([@send], arguments)

module.exports = LibratoClient
