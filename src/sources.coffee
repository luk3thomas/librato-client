UserAgent = require('./user-agent.coffee')
{ parseUserAgent } = require('./user-agent.coffee')

class Sources

  constructor: ->
    @TAGS =
      browser:  -> UserAgent.parseUserAgent().browser
      version:  -> UserAgent.parseUserAgent().version
      platform: -> UserAgent.parseUserAgent().platform

  # Creates a dynamic source from placeholder variables. e.g.
  #   source: 'browser.version.platform'
  # would become
  #   source: 'chrome.45.mac'
  createSource: (placeholder='', override) ->
    return override if override?
    placeholder.split('.')
      .map (tag) =>
        if fn = @TAGS[tag]
          fn.call(@)
        else
          tag
      .join '.'
      .slice(0, 255)

  createTags: (placeholder='') ->
    _.reduce(placeholder.split('.'), (o_tags, tag) =>
      o_tags[tag] = fn.call(@) if fn = @TAGS[tag]
      o_tags
    , {})

module.exports = Sources
