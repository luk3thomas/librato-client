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

  getType: (thing) ->
    Object.prototype.toString.call(thing).replace(/.* (.*)./, '$1')

  isEmpty: (thing) ->
    switch Utils.getType(thing)
      when "Array"  then thing.length is 0
      when "Object" then Object.keys(thing).length is 0
      else false

  isFunction: (thing) ->
    Utils.getType(thing) is "Function"

  isObject: (thing) ->
    Utils.getType(thing) is "Object"

  isUndefined: (thing) ->
    Utils.getType(thing) is "Undefined"

  isString: (thing) ->
    Utils.getType(thing) is "String"

  isNumber: (thing) ->
    Utils.getType(thing) is "Number" and not
    isNaN(thing)

module.exports = Utils
