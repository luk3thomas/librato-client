{ post } = require('xhr')
{ extend, compact } = require('utils')
Sources = require('sources')

class Sender
  constructor: (@client) ->
    { @prefix, @metric, @source, @headers, @endpoint } = @client.settings
    @sources  = new Sources()

  prepare: (data)->
    data.metric = compact([@prefix, @metric, data.metric]).join '.'
    data.source = @sources.createSource(@source, data.source)
    data

  send: (data) ->
    json = JSON.stringify(@prepare(data))
    post({ @endpoint
         , data: json
         , headers: extend({'Content-Type': 'application/json'}, @headers) })
    @client

module.exports = Sender
