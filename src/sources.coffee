{ toArray } = require('./utils.coffee')
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

module.exports = Sources
