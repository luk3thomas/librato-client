{ post } = require('./xhr.coffee')
{ compact, combineArray, extend } = require('./utils.coffee')
Sender = require('./sender.coffee')
Instruments = require('./instruments.coffee')

class LibratoClient
  constructor: (opts={}) ->
    { endpoint = '/'
    , prefix   = null
    , headers  = {}
    , metric   = null
    , source   = null } = opts

    @settings = { endpoint, prefix, headers, metric, source }
    @sender   = new Sender(@)

  # Fork methods for updating the client's settings
  fork: (opts={}) ->
    new LibratoClient(extend(@settings, opts))

  source: (source)     -> @fork { source }
  metric: (metric)     -> @fork { metric }
  prefix: (prefix)     -> @fork { prefix }
  headers: (headers)   -> @fork { headers }
  endpoint: (endpoint) -> @fork { endpoint }

  # Instrumentation methods
  increment: -> Instruments.increment.apply @, combineArray([@sender.send], arguments)
  measure:   -> Instruments.measure.apply   @, combineArray([@sender.send], arguments)
  timing:    -> Instruments.timing.apply    @, combineArray([@sender.send], arguments)

module.exports = LibratoClient
