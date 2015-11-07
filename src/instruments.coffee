{ curry, isNumber, isEmpty, isFunction } = require('./utils.coffee')

createRequest = (type, metric, opts, defaultValue) ->
  { source, value = defaultValue } = toOptions(opts)
  { type, metric, source, value }

toOptions = (opts={}) ->
  if isNumber(opts)
    value: opts
  else
    opts

Instruments =

  increment: (fn, metric, opts={}) ->
    fn.call @, createRequest('increment', metric, opts, 1)

  measure: curry (fn, metric, opts={}) ->
    fn.call @, createRequest('measure', metric, opts, 0)

  # TODO allow second param to be a function, like so
  # window.onload = librato.timing 'foo', (e) ->
  #   # This callback is executed onload and the timing measure is sent on
  #   # completion
  timing: (fn, metric, opts={}) ->
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
        fn.call(self, createRequest('timing', metric, opts, end - start))
      callback.call(null, done)

    # with a metric name and opts
    else if not isEmpty(opts) and metric?
      fn.call @, createRequest('timing', metric, opts, 0)

    # with a metric name only
    else if isEmpty(opts) and metric?
      (opts={}) ->
        end = +new Date()
        fn.call(self, createRequest('timing', metric, opts, end - start))

module.exports = Instruments
