{ curry, isNumber, isEmpty } = require('./utils.coffee')

measure = (type, metric, opts, defaultValue) ->
  if isNumber(opts)
    value = opts
  else
    { source, value } = opts
    value ?= defaultValue
  { type, metric, source, value }

Instruments =

  increment: (fn, metric, opts={}) ->
    fn.call @, measure('increment', metric, opts, 1)

  measure: curry (fn, metric, opts={}) ->
    fn.call @, measure('measure', metric, opts, 0)

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
        fn.call(self, measure('timing', metric, opts, end - start))
    else
      fn.call @, measure('timing', metric, opts, 0)

module.exports = Instruments
