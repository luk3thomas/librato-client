{ post } = require('src/xhr')
{ extend
, compact
, isEmpty
, getType } = require('src/utils')
{ INHERIT_TAGS } = require('src/constants')

class RequestQueue
  constructor: ({flushInterval, clientSettings}) ->
    @queue = []
    @settings = clientSettings
    @intervalId = setInterval(@flush.bind(@), flushInterval)
    # TODO flush on document unload

  add: ({ metric, tags, value, type }) =>
    tags = processTags(tags, @settings.tags)
    @queue.push({metric, tags, value, type})

  flush: ->
    @send(@queue)
    @queue = []

  send: (list) ->
    if not isEmpty(list)
      prefix = @settings.prefix
      data =
        JSON.stringify({
          measurements: list.map(prefixMetric(prefix))
        })
      headers = extend({'Content-Type': 'application/json'}, @settings.headers)
      endpoint = @settings.endpoint
      post({ endpoint, data, headers })

  destroy: ->
    clearInterval(@intervalId)

# private

prefixMetric = (prefix) ->
  (data) ->
    if prefix
      data.metric = "#{prefix}.#{data.metric}"
    data

maybeMergeSettingsTags = (tags, settingsTags) ->
  baseTags = {}

  switch getType(tags[INHERIT_TAGS])
    when "String"
      baseTags[tags[INHERIT_TAGS]] = settingsTags[tags[INHERIT_TAGS]]
    when "Array"
      for tag in tags[INHERIT_TAGS]
        baseTags[tag] = settingsTags[tag]
    when "Boolean"
      if tags[INHERIT_TAGS]
        baseTags = settingsTags

  extend({}, tags, baseTags)

processTags = (tags, settingsTags) ->
  mergedTags = maybeMergeSettingsTags(tags, settingsTags)
  Object.keys(mergedTags)
    .filter (key) -> mergedTags[key]?
    .filter (key) -> '$' not in key
    .reduce (result, key) ->
      result[key] = mergedTags[key].toString()
      result
    , {}

module.exports = RequestQueue
