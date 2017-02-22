UserAgent = require('src/user-agent')

describe 'UserAgent', ->

  beforeEach ->
    sinon.stub(UserAgent, 'getUA')
    @ua =
      chrome: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36'
      firefox: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:40.0) Gecko/20100101 Firefox/40.0'
      safari: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10) AppleWebKit/600.1.25 (KHTML, like Gecko) Version/8.0 Safari/600.1.25'
      ie: 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko'
      ie10: 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)'

    @platform =
      mac: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36'
      windows: 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko'
      linux: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.137 Safari/4E423F'
      android: 'Mozilla/5.0 (Linux; Android 5.1.1; Nexus 5 Build/LMY48B; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/43.0.2357.65 Mobile Safari/537.36'

    @result = (ua) ->
      UserAgent.getUA.returns(ua)
      UserAgent.parseUserAgent()

  afterEach ->
    UserAgent.getUA.restore()


  it 'parses ua string', ->
    # UA strings
    expect(@result(@ua.chrome))  .toEqual browser: 'chrome',  version: '45', platform: 'mac'
    expect(@result(@ua.firefox)) .toEqual browser: 'firefox', version: '40', platform: 'mac'
    expect(@result(@ua.safari))  .toEqual browser: 'safari',  version:  '8', platform: 'mac'
    expect(@result(@ua.ie))      .toEqual browser: 'ie',      version: '11', platform: 'windows'
    expect(@result(@ua.ie10))    .toEqual browser: 'ie',      version: '10', platform: 'windows'

    # Various platforms
    expect(@result(@platform.mac))     .toEqual browser: 'chrome', version: '45', platform: 'mac'
    expect(@result(@platform.linux))   .toEqual browser: 'chrome', version: '34', platform: 'linux'
    expect(@result(@platform.windows)) .toEqual browser: 'ie',     version: '11', platform: 'windows'
    expect(@result(@platform.android)) .toEqual browser: 'chrome', version: '43', platform: 'android'

  it '#normalizeName', ->
    expect(UserAgent.normalizeVersion('45.03483.3403.3')).toBe '45'
    expect(UserAgent.normalizeVersion()).toBe '', 'Handles undefined'

    # Edge cases from https://github.com/faisalman/ua-parser-js
    expect(UserAgent.normalizeName('Mac OS'))         .toBe 'mac'
    expect(UserAgent.normalizeName('[Phone/Mobile]')) .toBe 'phone'
    expect(UserAgent.normalizeName('OS/2'))           .toBe 'os'
    expect(UserAgent.normalizeName()).toBe '', 'Handles undefined'
