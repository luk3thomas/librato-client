Sources = require('../../src/sources.coffee')
UserAgent = require('../../src/user-agent.coffee')
sinon = require('sinon')

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
      sinon.stub(@sources, 'pathname')

      @expectPage = (path, expectation, message) ->
        @sources.pathname.returns(path)
        expect(@sources.createSource('page')).toBe expectation, message

    it 'page', ->
      @expectPage('/s/spaces/1',            'space',          'Single space')
      @expectPage('/s/spaces/1/',           'space',          'Single space trailing slash')
      @expectPage('/s/spaces/1/sd',         'space',          'Single space jank')
      @expectPage('/s/spaces',              'spaces',         'Spaces index')
      @expectPage('/s/spaces/',             'spaces',         'Spaces index trailing slash')
      @expectPage('/s/metrics',             'metrics',        'Metrics index')
      @expectPage('/s/metrics/',            'metrics',        'Metrics index trailing slash')
      @expectPage('/s/metrics/foo',         'metric',         'Single metrics')
      @expectPage('/s/metrics/foo/',        'metric',         'Single metrics trailing slash')
      @expectPage('/s/metrics/foo/asdf',    'metric',         'Single metrics jank')
      @expectPage('/s/spaces/1/explore/1',  'space-explore',  'Explore view')
      @expectPage('/s/spaces/1/explore/1/', 'space-explore',  'Explore view, trailing slash')
      @expectPage('/s/public/sdfdfb',       'public',         'Public view')
      @expectPage('/s/public/sdfdfb/',      'public',         'Public view, trailing slash')

    it 'browser, version, platform', ->
      expect(@sources.createSource('browser.version.platform')).toBe 'chrome.45.mac'

      template = 'browser.version.hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh'

      expect(@sources.createSource(template).length).toBe 255, 'Error Message over 255 chars'
