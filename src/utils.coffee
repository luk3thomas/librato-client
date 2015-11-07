# The frontend instrumentation shouldn't contain any third party dependencies.
# These are convenience functions we're using in the library.

window.Librato = window.Librato or {}

toArray = (d) -> [].slice.call(d)

currify = (fn, args, remaining)->
  if remaining < 1
    fn.apply(null, args)
  else
    -> currify(fn, args.slice(0, fn.length - 1).concat(toArray(arguments)), remaining - arguments.length)

Utils =

  toArray: toArray

  compact: (array) ->
    array.filter (v) -> v?

  curry: (fn) ->
    -> currify(fn, toArray(arguments), fn.length - arguments.length)

  isEmpty: (object) ->
    typeof object is 'object' and Object.keys(object).length is 0

  isNumber: (number) ->
    ( typeof number is 'number' and
      not isNaN(number) )

  combineArray: ->
    toArray(arguments).reduce (result, array) ->
      result.concat(toArray(array))
    , []

module.exports = Utils
