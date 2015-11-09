{ isNumber
, isEmpty
, isString
, isFunction } = require('./utils.coffee')

createRequest = (type, metric, opts, defaultValue) ->
  { source, value = defaultValue } = toOptions(opts)
  { type, metric, source, value }

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
    if !isString(metric)
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
      done = (opts={}) ->
        end = +new Date()
        self.instrument 'timing', metric, opts, end - start
      callback.call(null, done)

    # with a metric name and opts
    else if not isEmpty(opts) and metric?
      @instrument 'timing', metric, opts, 0

    # with a metric name only
    else if isEmpty(opts) and metric?
      (opts={}) ->
        end = +new Date()
        self.instrument 'timing', metric, opts, end - start

module.exports = Instruments
