UAParser = require('ua-parser-js')

class UserAgent
  constructor: (ua) ->
    @ua = ua
    @parser = new UAParser(@ua)

  # Need to set the UA string for testing
  setUA: (ua) ->
    @parser.setUA(ua)

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
    result = @parser.getResult()

    browser  = (result.browser.name or '').toLowerCase()
    version  = @normalizeVersion(result.browser.version)
    platform = @normalizeName(result.os.name)

    { browser, version, platform }

module.exports = UserAgent
