Sources = require('../../src/sources.coffee')
UserAgent = require('../../src/user-agent.coffee')
sinon = require('sinon/pkg/sinon')

describe 'Sources', ->

  beforeEach ->
    @sources = new Sources()
    sinon.stub(UserAgent, 'getUA').returns 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36'

  afterEach ->
    UserAgent.getUA.restore()

  it '#createSource', ->
    expect(@sources.createSource('browser.version.user_id')).toBe 'chrome.45.user_id', 'static string is okay'

  describe 'tags', ->

    beforeEach ->
      @expectPage = (path, expectation, message) ->
        expect(@sources.createSource('page')).toBe expectation, message

    it 'browser, version, platform', ->
      expect(@sources.createSource('browser.version.platform')).toBe 'chrome.45.mac'

      template = 'browser.version.hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh'

      expect(@sources.createSource(template).length).toBe 255, 'Error Message over 255 chars'
