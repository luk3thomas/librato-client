{ curry, isNumber, isEmpty } = require('./utils.coffee')

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
    if isEmpty(opts)
      start = +new Date()
      (opts={}) ->
        end = +new Date()
        fn.call(self, createRequest('timing', metric, opts, end - start))
    else
      fn.call @, createRequest('timing', metric, opts, 0)

module.exports = Instruments
