# The purpose of Instrument is to accept various inputs and return a
# consistent data object representing the measurements of our application.
#
# NOTE
# The first param {fn} of each method is injected by Librato.Client which
# processes and transmits the returned data.

# Increment
# =========
# Instrument.increment 'foo'
# Instrument.increment 'foo', { source: 'bar', value: 2 }
#
# Measurement
# ===========
# Instrument.measure 'foo', 42
# Instrument.measure 'foo', { source: 'bar', value: 42 }
#
# measureFoo = Instrument.measure 'foo'  # Measure metric multiple times
# measureFoo 42                                  #  sends measure
# measureFoo 57                                  #  sends measure, again
# measureFoo { source: 'bar', value: 42}         #  sends measure, yet again
#
# Timing
# ======
# Instrument.timing 'foo', 345       # manually send timing value
#
# fn = Instrument.timing 'foo'       # Start timer
# fn()                                       #   sends calculated time by default
# fn { source: 'bar', value: 345 }           #   or override value if you want, whatevs

{ curry, isNumber, isEmpty } = require('./utils.coffee')

# Coalesces the output of every instrument to a standard data structure e.g.
# { type: 'timing',
#   metric: 'foo',
#   source: 'bar',
#   value: 247 }

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
