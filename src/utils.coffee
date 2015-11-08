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

  extend: ->
    toArray(arguments).reduce (result, object) ->
      result[k] = v for k, v of object
      result
    , {}

  curry: (fn) ->
    -> currify(fn, toArray(arguments), fn.length - arguments.length)

  isEmpty: (object) ->
    typeof object is 'object' and Object.keys(object).length is 0

  isFunction: (fn) ->
    typeof fn is 'function'

  isNumber: (number) ->
    ( typeof number is 'number' and
      not isNaN(number) )

  combineArray: ->
    toArray(arguments).reduce (result, array) ->
      result.concat(toArray(array))
    , []

module.exports = Utils
