UAParser = require('ua-parser-js')

UserAgent =
  getUA: ->
    navigator.userAgent

  normalizeName: (name) ->
    (name or '')
      .replace /\W/g, ' '
      .trim()
      .split(' ')[0]
      .toLowerCase()

  normalizeVersion: (version) ->
    (version or '').split('.')[0]

  # Returns the browser, version, and platform for a userAgent string.
  parseUserAgent: ->
    ua     = UserAgent.getUA()
    result = new UAParser(ua).getResult()

    browser  = (result.browser.name or '').toLowerCase()
    version  = UserAgent.normalizeVersion(result.browser.version)
    platform = UserAgent.normalizeName(result.os.name)

    { browser, version, platform }

module.exports = UserAgent
