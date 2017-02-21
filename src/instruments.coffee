{ isNumber
, isObject
, isString
, isUndefined
, isFunction } = require('src/utils')
{ TIMING_START } = require('src/constants')

Instruments =

  measure: ({args, done}) ->
    [ metric, tags={}, value=1 ] = args

    # tags are optional
    if isNumber(tags)
      value = tags
      tags = {}

    validateTags(tags)
    validateValue(value)
    validateMetric(metric)

    done({metric, tags, type: 'measure', value})

  timing: ({args, done}) ->
    [ metric, tags={}, callback ] = args
    start = new Date()

    # tags are optional
    if isFunction(tags)
      callback = tags
      tags = {}

    validateTags(tags)
    validateMetric(metric)
    validateCallback(callback)

    timingCallback =
      (value) ->
        end = new Date()
        # Possibly backdate the start time
        if tags[TIMING_START]
          start = tags[TIMING_START]
          delete tags[TIMING_START]
        done({
          metric,
          tags,
          type: 'timing',
          value: end - start
        })
        value

    if isUndefined(callback)
      timingCallback
    else if isFunction(callback)
      callback.call(callback, timingCallback)

# private

validateMetric = (metric) ->
  if not isString(metric)
    throw new TypeError("metric must be a string")

validateTags = (tags) ->
  if not isObject(tags)
    throw new TypeError("tags must be an object")

validateValue = (value) ->
  if isNaN(value) or not isNumber(value)
    throw new TypeError("value must be a number")

validateCallback = (callback) ->
  if callback?
    if not isFunction(callback)
      throw new TypeError("callback must be a function")

module.exports = Instruments
