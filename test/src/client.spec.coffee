LibratoClient = require('../../src/librato-client.coffee')
sinon = require('sinon')

describe 'LibratoClient', ->
  beforeEach ->
    @client = new LibratoClient()
    sinon.stub(@client, 'xhr').returns
      open: sinon.spy()
      send: sinon.spy()
      setRequestHeader: sinon.spy()

  it '#send', ->
    data =
      metric: 'foo'
      source: 'bar'
      value: 1
      type: 'increment'

    @client.endpoint = '/tmp'
    @client.send(data)

    expect(@client.xhr().open.args.length) .toBe 1
    expect(@client.xhr().open.args[0][0])  .toBe 'POST'
    expect(@client.xhr().open.args[0][1])  .toBe '/tmp'
    expect(@client.xhr().open.args[0][2])  .toBe true

    expect(@client.xhr().setRequestHeader.args.length) .toBe 1
    expect(@client.xhr().setRequestHeader.args[0][0])  .toBe 'Content-Type'
    expect(@client.xhr().setRequestHeader.args[0][1])  .toBe 'application/json'

    @client.headers = {'X-TOKEN': 'foo'}
    @client.send(data)

    expect(@client.xhr().setRequestHeader.args.length) .toBe 3
    expect(@client.xhr().setRequestHeader.args[1][0])  .toBe 'Content-Type',     'With custom headers'
    expect(@client.xhr().setRequestHeader.args[1][1])  .toBe 'application/json', 'With custom headers'
    expect(@client.xhr().setRequestHeader.args[2][0])  .toBe 'X-TOKEN',          'With custom headers'
    expect(@client.xhr().setRequestHeader.args[2][1])  .toBe 'foo',              'With custom headers'

    expect(@client.send(data) instanceof LibratoClient).toBe true, 'Chains to self'

  it '#fork', ->
    @client = new LibratoClient
      endpoint: '/original'
      prefix: 'foo'
      headers:
        'X-FOO': 'bar'

    @client2 = @client.fork
      endpoint: '/forked'
      prefix: 'foo.fork'
      headers:
        'X-FORK': 'bar'

    expect(@client.endpoint)           .toBe '/original',  'Original client'
    expect(@client.prefix)             .toBe 'foo',        'Original client'
    expect(@client.headers['X-FOO'])   .toBe 'bar',        'Original client'
    expect(@client.headers['X-FORK'])  .toBeUndefined      'Original client'

    expect(@client2).not               .toBe @client,      'Forked client'
    expect(@client2.endpoint)          .toBe '/forked',    'Forked client'
    expect(@client2.prefix)            .toBe 'foo.fork',   'Forked client'
    expect(@client2.headers['X-FORK']) .toBe 'bar',        'Forked client'
    expect(@client2.headers['X-FOO'])  .toBeUndefined      'Forked client'

  it '#withSource', ->
    @client = new LibratoClient
      endpoint: '/original'
      prefix: 'foo'
      source: 'browser'
      headers:
        'X-FOO': 'bar'

    @client2 = @client.withSource('version')

    expect(@client.endpoint)           .toBe '/original',  'Original client'
    expect(@client.prefix)             .toBe 'foo',        'Original client'
    expect(@client.source)             .toBe 'browser',    'Original client'
    expect(@client.headers['X-FOO'])   .toBe 'bar',        'Original client'
    expect(@client.headers['X-FORK'])  .toBeUndefined      'Original client'

    expect(@client2.endpoint)           .toBe '/original',  'New source client'
    expect(@client2.prefix)             .toBe 'foo',        'New source client'
    expect(@client2.source)             .toBe 'version',    'New source client'
    expect(@client2.headers['X-FOO'])   .toBe 'bar',        'New source client'
    expect(@client2.headers['X-FORK'])  .toBeUndefined      'New source client'
  it '#prepare', ->
    data =
      metric: 'foo'
      source: 'bar'
      value: 1
      type: 'increment'

    prepared = @client.prepare(data)

    expect(prepared.metric) .toBe 'foo',       'Default options'
    expect(prepared.source) .toBe 'bar',       'Default options'
    expect(prepared.type)   .toBe 'increment', 'Default options'
    expect(prepared.value)  .toBe 1,           'Default options'

  describe 'instrumentation', ->
    beforeEach ->
      sinon.stub(@client, 'send')

    it '#increment', ->
      @client.increment 'foo'
      @client.increment 'foo', 5
      @client.increment 'foo', source: 'bar', value: 5

      expect(@client.send.args.length).toBe 3

      expect(@client.send.args[0][0].metric) .toBe 'foo'
      expect(@client.send.args[0][0].type)   .toBe 'increment'
      expect(@client.send.args[0][0].value)  .toBe 1
      expect(@client.send.args[0][0].source) .toBeUndefined()

      expect(@client.send.args[1][0].metric) .toBe 'foo'
      expect(@client.send.args[1][0].type)   .toBe 'increment'
      expect(@client.send.args[1][0].value)  .toBe 5
      expect(@client.send.args[1][0].source) .toBeUndefined()

      expect(@client.send.args[2][0].metric) .toBe 'foo'
      expect(@client.send.args[2][0].type)   .toBe 'increment'
      expect(@client.send.args[2][0].value)  .toBe 5
      expect(@client.send.args[2][0].source) .toBe 'bar'

    it '#measure', ->
      @client.measure 'foo', 5

      expect(@client.send.args.length).toBe 1

      expect(@client.send.args[0][0].metric) .toBe 'foo'
      expect(@client.send.args[0][0].type)   .toBe 'measure'
      expect(@client.send.args[0][0].value)  .toBe 5
      expect(@client.send.args[0][0].source) .toBeUndefined()

    it '#timing', (done) ->
      @client.timing 'foo', 5

      expect(@client.send.args.length).toBe 1

      expect(@client.send.args[0][0].metric) .toBe 'foo'
      expect(@client.send.args[0][0].type)   .toBe 'timing'
      expect(@client.send.args[0][0].value)  .toBe 5
      expect(@client.send.args[0][0].source) .toBeUndefined()

      timer = @client.timing 'async'

      setTimeout =>
        timer()
        expect(@client.send.args[1][0].metric) .toBe 'async'
        expect(@client.send.args[1][0].type)   .toBe 'timing'
        expect(@client.send.args[1][0].value)  .toBeGreaterThan 29
        expect(@client.send.args[1][0].source) .toBeUndefined()
        done()
      , 30
