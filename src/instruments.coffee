{ isNumber
, isEmpty
, isString
, isFunction } = require('utils')

createRequest = (type, metric, opts, defaultValue) ->
  { source, value = defaultValue } = toOptions(opts)
  { type, metric, source, value }

createTimingCallback = (context, metric, start) ->
  (value) ->
    end = +new Date()
    context.instrument 'timing', metric, {}, end - start
    value

toOptions = (opts={}) ->
  if isNumber(opts)
    value: opts
  else
    opts

class Instruments

  constructor: (sender) ->
    @sender = sender

  instrument: (type, metric, opts, defaultValue) ->
    @sender.send createRequest(type, metric, opts, defaultValue)

  increment: (metric, opts={}) ->
    @instrument 'increment', metric, opts, 1

  measure: (metric, opts={}) ->
    self = @
    debugger
    if not isString(metric)
      opts   = metric
      metric = null
    else if isEmpty(opts)
      return (opts={}) ->
        self.instrument 'measure', metric, opts, 0
    @instrument 'measure', metric, opts, 0

  timing: (metric, opts={}) ->
    self = @
    start = +new Date()

    # with a callback
    if isFunction(opts) or isFunction(metric)
      if isFunction(metric)
        callback = metric
        metric = undefined
      else
        callback = opts
      done = createTimingCallback(self, metric, start)
      callback.call(null, done)

    # with a metric name with an explicit value
    else if not isEmpty(opts) and metric?
      if opts.start?
        createTimingCallback(self, metric, opts.start)
      else
        @instrument 'timing', metric, opts, 0

    else if isEmpty(opts)
      # with a callback
      if typeof metric is 'object' and metric.start?
        createTimingCallback(self, undefined, metric.start)
      # with an explicit value
      else if not isString(metric)
        @instrument 'timing', undefined, metric, 0
      # with a callback
      else
        createTimingCallback(self, metric, start)

module.exports = Instruments
