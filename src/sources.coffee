{ toArray } = require('./utils.coffee')
UserAgent = require('./user-agent.coffee')

class Sources

  constructor: ->
    @userAgent = new UserAgent()

    # A map of custom args to tag names. Useful if you want to build the source
    # from information supplied in a callback. window.onerror is a good example
    # if we want to add the file name or error message to the source
    @ARGS_MAP = {}

    # The custom placeholder tags
    @TAGS =
      page: ->
        @pathname()
          .replace /\/s\//,                     ''       # remove beginning /s/
          .replace /^(\w+)s\/\d+\/?$/,          '$1'     # space  /s/spaces/1
          .replace /^(\w+)s\/\d+\/(\w+)\/.+/,   '$1-$2'  # explore  /s/spaces/1/explore/4
          .replace /^(\w+)s\/.+/,               '$1'     # metric /s/metrics/foo
          .replace /^([^\/]+).*/,               '$1'     # Keep first pathname, e.g. /s/public/adb3h32
          .replace /\/$/,                       ''       # remove trailing slash
      browser:  -> @userAgent.parseUserAgent().browser
      version:  -> @userAgent.parseUserAgent().version
      platform: -> @userAgent.parseUserAgent().platform

  pathname: ->
    location.pathname

  # Adds parameters to the tag callbacks. Helpful if you want to dynamically
  # create a source from a veriable e.g. error reporting
  addTagArg: ->
    @ARGS_MAP[arguments[0]] = toArray(arguments).slice(1)

  # Creates a dynamic source from placeholder variables. e.g.
  #   source: 'browser.version.platform'
  # would become
  #   source: 'chrome.45.mac'
  createSource: (placeholder, override) ->
    return override if override?
    placeholder.split('.')
      .map (tag) =>
        if fn = @TAGS[tag]
          if args = @ARGS_MAP[tag]
            fn.apply(@, args)
          else
            fn.call(@)
        else
          tag
      .join '.'
      .slice(0, 255)

module.exports = Sources
