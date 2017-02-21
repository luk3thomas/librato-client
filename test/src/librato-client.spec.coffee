LibratoClient = require('src/librato-client')
Promise = require('bluebird')
XHR = require('src/xhr')
UserAgent = require('src/user-agent')

describe 'LibratoClient', ->
  beforeEach ->
    @fakeXHR =
      open: sinon.spy()
      send: sinon.spy()
      setRequestHeader: sinon.spy()
    sinon.stub(XHR, 'xhr').returns(@fakeXHR)
    sinon.stub(UserAgent, 'parseUserAgent').returns {
      browser: 'tester'
      version: '1'
      platform: 'os'
    }
    @client = new LibratoClient()
    sinon.stub(@client.requestQueue, 'add')
    sinon.stub(console, 'error')

  afterEach ->
    XHR.xhr.restore()
    UserAgent.parseUserAgent.restore()
    console.error.restore()

  it 'catches errors', ->
    expect(console.error.callCount).toBe 0
    expect(=> @client.measure('sdf', [], [])).not.toThrow()
    expect(console.error.callCount).toBe 1

  it 'stringifies tag values and removes reserved keys', (done) ->
    @client = new LibratoClient({
      flushInterval: 8 # 8ms
    })
    sinon.spy(@client.requestQueue, 'send')
    @client.measure('foo', {
      null: null,
      undefined: undefined,
      number: 1,
      bool: true,
      nan: NaN,
      infinity: Infinity,
      $start_time: 1,
      a: "a"
    })
    setTimeout =>
      [ { tags } ] = @client.requestQueue.send.lastCall.args[0]
      expect(tags).toEqual
        number: '1'
        bool: 'true'
        nan: 'NaN'
        infinity: 'Infinity'
        a: 'a'
      done()
    , 10

  describe '#measure', ->

    it 'sends a metric measure', ->
      @client.measure('foo', 5)
      {metric, tags, value, type} = @client.requestQueue.add.lastCall.args[0]

      expect(metric).toBe 'foo'
      expect(type).toBe 'measure'
      expect(tags).toEqual {}
      expect(value).toBe 5

    it 'sends tags', ->
      @client.measure('foo', {foo: "1", bar: "2"}, 5)
      {metric, tags, value} = @client.requestQueue.add.lastCall.args[0]

      expect(metric).toBe 'foo'
      expect(tags).toEqual {foo: "1", bar: "2"}
      expect(value).toBe 5

  describe '#timing', ->

    it 'works as an implied callback', (done) ->
      cb = @client.timing('foo', { hello: 'ben' })
      setTimeout =>
        cb()
        {metric, tags, value, type} = @client.requestQueue.add.lastCall.args[0]
        expect(metric).toBe 'foo'
        expect(type).toBe 'timing'
        expect(tags).toEqual {hello: 'ben'}
        expect(value).toBeGreaterThan 19
        done()
      , 20

    it 'works with a specified callback', (done) ->
      @client.timing('foo', { hello: 'ben' }, (d) ->
        d()
      )
      setTimeout =>
        {metric, tags, value} = @client.requestQueue.add.lastCall.args[0]
        expect(metric).toBe 'foo'
        expect(tags).toEqual {hello: 'ben'}
        expect(value).toBeLessThan 10
        done()
      , 10

    it 'can backdate the start time', ->
      start = new Date() - 100
      cb = @client.timing('foo', { hello: 'ben', $start_time: start })
      cb()
      {metric, tags, value} = @client.requestQueue.add.lastCall.args[0]
      expect(metric).toBe 'foo'
      expect(tags).toEqual {hello: 'ben'}
      expect(value).toBe 100

  describe '#requestQueue', ->

    it "sends data", (done) ->
      @client = new LibratoClient({
        flushInterval: 5 # 5ms
        endpoint: '/collect'
        prefix: 'ui'
      })
      sinon.spy(@client.requestQueue, 'send')
      @client.measure('foo', { hey: 'ben' }, 1)
      @client.measure('foo', { hey: 'baz' }, 2)
      @client.measure('foo', { hey: 'bon' }, 3)
      setTimeout =>
        json = JSON.parse(@fakeXHR.send.lastCall.args[0])
        [method, endpoint] = @fakeXHR.open.lastCall.args
        expect(@client.requestQueue.send.callCount).toBeGreaterThan 1
        expect(@fakeXHR.open.callCount).toBe 1
        expect(method).toBe 'POST'
        expect(endpoint).toBe '/collect'
        expect(json).toEqual {
          measurements: [
            { metric: 'ui.foo', tags: { hey: 'ben' }, value: 1, type: 'measure' }
            { metric: 'ui.foo', tags: { hey: 'baz' }, value: 2, type: 'measure' }
            { metric: 'ui.foo', tags: { hey: 'bon' }, value: 3, type: 'measure' }
          ]
        }
        done()
      , 20

    it "merges base tags", (done) ->
      @client = new LibratoClient({
        flushInterval: 5 # 5ms
        endpoint: '/collect'
        tags: { env: 'test' }
        prefix: 'ui'
      })
      sinon.spy(@client.requestQueue, 'send')
      @client.measure('foo', { hey: 'ben', $inherit: true }, 1)
      setTimeout =>
        json = JSON.parse(@fakeXHR.send.lastCall.args[0])
        expect(json).toEqual {
          measurements: [
            { metric: 'ui.foo', tags: { hey: 'ben', env: 'test' }, value: 1, type: 'measure' }
          ]
        }
        done()
      , 20

    it "merges selective tags tags, browser info", (done) ->
      @client = new LibratoClient({
        flushInterval: 5 # 5ms
        endpoint: '/collect'
        includeBrowserInfo: true
        tags: { env: 'test' }
        prefix: 'ui'
      })
      sinon.spy(@client.requestQueue, 'send')
      @client.measure('foo', { hey: 'ben', $inherit: 'env' }, 1)
      @client.measure('foo', { hey: 'ben', $inherit: true }, 2)
      @client.measure('foo', { hey: 'ben', $inherit: ['browser', 'platform', '404'] }, 3)
      setTimeout =>
        json = JSON.parse(@fakeXHR.send.lastCall.args[0])
        expect(json.measurements[0]).toEqual { metric: 'ui.foo', type: 'measure', tags: { hey: 'ben', env: 'test' }, value: 1 }
        expect(json.measurements[1]).toEqual { metric: 'ui.foo', type: 'measure', tags: { hey: 'ben', env: 'test', browser: 'tester', version: '1', platform: 'os' }, value: 2 }
        expect(json.measurements[2]).toEqual { metric: 'ui.foo', type: 'measure', tags: { hey: 'ben', browser: 'tester', platform: 'os' }, value: 3 }
        done()
      , 20
