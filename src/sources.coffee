UserAgent = require('user-agent')
{ parseUserAgent } = require('user-agent')

class Sources

  constructor: ->
    @TAGS =
      browser:  -> parseUserAgent().browser
      version:  -> parseUserAgent().version
      platform: -> parseUserAgent().platform

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
