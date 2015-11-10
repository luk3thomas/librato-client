toArray = (d) -> [].slice.call(d)

Utils =

  toArray: toArray

  compact: (array) ->
    array.filter (v) -> v?

  extend: ->
    toArray(arguments).reduce (result, object) ->
      result[k] = v for k, v of object
      result
    , {}

  isEmpty: (object) ->
    typeof object is 'object' and Object.keys(object).length is 0

  isFunction: (fn) ->
    typeof fn is 'function'

  isString: (string) ->
    typeof string is 'string'

  isNumber: (number) ->
    ( typeof number is 'number' and
      not isNaN(number) )

module.exports = Utils
