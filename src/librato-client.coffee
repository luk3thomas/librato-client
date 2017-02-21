{ post } = require('src/xhr')
{ extend } = require('src/utils')
RequestQueue = require('src/request-queue')
Instruments = require('src/instruments')
UserAgent = require('src/user-agent')

class LibratoClient
  constructor: (opts={}) ->
    { endpoint = '/'
    , prefix   = null
    , headers  = {}
    , tags     = {}
    , flushInterval = 5000
    , includeBrowserInfo = false
    } = opts

    if includeBrowserInfo
      tags = extend({}, tags, UserAgent.parseUserAgent())

    @settings = { endpoint, prefix, headers, tags }
    @requestQueue = new RequestQueue({ flushInterval, clientSettings: @settings })

  flush: ->
    @requestQueue.flush()

  destroy: ->
    @requestQueue.destroy()

  # Instrumentation methods
  timing:    -> instrument('timing', arguments, @requestQueue.add)
  measure:   -> instrument('measure', arguments, @requestQueue.add)

# private

instrument = (type, args, done) ->
  try
    switch type
      when 'timing'     then Instruments.timing({args, done})
      when 'measure'    then Instruments.measure({args, done})
  catch error
    console.error "LibratoClient error", error

module.exports = LibratoClient
