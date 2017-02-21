{ post } = require('./xhr.coffee')
{ extend, compact } = require('./utils.coffee')
Sources = require('./sources.coffee')
_       = require 'lodash'

class Sender
  constructor: (@client) ->
    { @prefix, @metric, @source, @headers, @endpoint } = @client.settings
    @sources  = new Sources()

  prepare: (data)->
    data.metric = compact([@prefix, @metric, data.metric]).join '.'
    if "source" of data
      data.source = @sources.createSource(@source, data.source)
    if "tags" of data
      data.tags = _.merge(data.tags, @sources.createTags(@source))
    data

  send: (data) ->
    json = JSON.stringify(@prepare(data))
    post({ @endpoint
         , data: json
         , headers: extend({'Content-Type': 'application/json'}, @headers) })
    @client

module.exports = Sender
