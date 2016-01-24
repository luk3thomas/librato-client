{ post } = require('./xhr.js')
{ extend } = require('./utils.coffee')
Sender = require('./sender.coffee')
Instruments = require('./instruments.coffee')

class LibratoClient
  constructor: (opts={}) ->
    { endpoint = '/'
    , prefix   = null
    , headers  = {}
    , metric   = null
    , source   = null } = opts

    @settings    = { endpoint, prefix, headers, metric, source }
    @sender      = new Sender(@)
    @instruments = new Instruments(@sender)

  # Fork methods for updating the client's settings
  fork: (opts={}) ->
    new LibratoClient(extend(@settings, opts))

  source: (source)     -> @fork { source }
  metric: (metric)     -> @fork { metric }
  prefix: (prefix)     -> @fork { prefix }
  headers: (headers)   -> @fork { headers }
  endpoint: (endpoint) -> @fork { endpoint }

  # Instrumentation methods
  timing:    -> @instruments.timing.apply @instruments, arguments
  measure:   -> @instruments.measure.apply @instruments, arguments
  increment: -> @instruments.increment.apply @instruments, arguments

module.exports = LibratoClient
