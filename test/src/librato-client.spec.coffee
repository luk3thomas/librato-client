LibratoClient = require('../../src/librato-client.coffee')
XHR = require('../../src/xhr.coffee')
sinon = require('sinon')

describe 'LibratoClient', ->
  beforeEach ->
    sinon.stub(XHR, 'xhr').returns
      open: sinon.spy()
      send: sinon.spy()
      setRequestHeader: sinon.spy()
    @client = new LibratoClient()

  afterEach ->
    XHR.xhr.restore()

  it '#send', ->
    data =
      metric: 'foo'
      source: 'bar'
      value: 1
      type: 'increment'

    @client = @client.endpoint('/tmp')
    @client.send(data)

    expect(XHR.xhr().open.args.length) .toBe 1
    expect(XHR.xhr().open.args[0][0])  .toBe 'POST'
    expect(XHR.xhr().open.args[0][1])  .toBe '/tmp'
    expect(XHR.xhr().open.args[0][2])  .toBe true

    expect(XHR.xhr().setRequestHeader.args.length) .toBe 1
    expect(XHR.xhr().setRequestHeader.args[0][0])  .toBe 'Content-Type'
    expect(XHR.xhr().setRequestHeader.args[0][1])  .toBe 'application/json'

    @client = @client.headers {'X-TOKEN': 'foo'}
    @client.send(data)

    expect(XHR.xhr().setRequestHeader.args.length) .toBe 3
    expect(XHR.xhr().setRequestHeader.args[1][0])  .toBe 'Content-Type',     'With custom headers'
    expect(XHR.xhr().setRequestHeader.args[1][1])  .toBe 'application/json', 'With custom headers'
    expect(XHR.xhr().setRequestHeader.args[2][0])  .toBe 'X-TOKEN',          'With custom headers'
    expect(XHR.xhr().setRequestHeader.args[2][1])  .toBe 'foo',              'With custom headers'

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

    expect(@client.settings.endpoint)           .toBe '/original',  'Original client'
    expect(@client.settings.prefix)             .toBe 'foo',        'Original client'
    expect(@client.settings.headers['X-FOO'])   .toBe 'bar',        'Original client'
    expect(@client.settings.headers['X-FORK'])  .toBeUndefined      'Original client'

    expect(@client2).not               .toBe @client,      'Forked client'
    expect(@client2.settings.endpoint)          .toBe '/forked',    'Forked client'
    expect(@client2.settings.prefix)            .toBe 'foo.fork',   'Forked client'
    expect(@client2.settings.headers['X-FORK']) .toBe 'bar',        'Forked client'
    expect(@client2.settings.headers['X-FOO'])  .toBeUndefined      'Forked client'

  describe 'fork methods', ->

    beforeEach ->
      @client = new LibratoClient
        endpoint: '/original'
        prefix: 'foo'
        source: 'browser'
        headers:
          'X-FOO': 'bar'

    afterEach ->
      expect(@client.settings.endpoint)           .toBe '/original',  'Original client'
      expect(@client.settings.prefix)             .toBe 'foo',        'Original client'
      expect(@client.settings.source)             .toBe 'browser',    'Original client'
      expect(@client.settings.headers['X-FOO'])   .toBe 'bar',        'Original client'
      expect(@client.settings.headers['X-FORK'])  .toBeUndefined      'Original client'


    it '#source', ->
      @client2 = @client.source('bar')
      expect(@client2.settings.endpoint)           .toBe '/original',  'New source client'
      expect(@client2.settings.prefix)             .toBe 'foo',        'New source client'
      expect(@client2.settings.metric)             .toBeNull           'New source client'
      expect(@client2.settings.source)             .toBe 'bar',        'New source client'
      expect(@client2.settings.headers['X-FOO'])   .toBe 'bar',        'New source client'
      expect(@client2.settings.headers['X-FORK'])  .toBeUndefined      'New source client'

    it '#metric', ->
      @client2 = @client.metric('foo.bar')
      expect(@client2.settings.endpoint)           .toBe '/original',  'New metric client'
      expect(@client2.settings.prefix)             .toBe 'foo',        'New metric client'
      expect(@client2.settings.metric)             .toBe 'foo.bar',    'New metric client'
      expect(@client2.settings.source)             .toBe 'browser',    'New metric client'
      expect(@client2.settings.headers['X-FOO'])   .toBe 'bar',        'New metric client'
      expect(@client2.settings.headers['X-FORK'])  .toBeUndefined      'New metric client'

    it '#prefix', ->
      @client2 = @client.prefix('ui')
      expect(@client2.settings.endpoint)           .toBe '/original',  'New prefix client'
      expect(@client2.settings.prefix)             .toBe 'ui',         'New prefix client'
      expect(@client2.settings.metric)             .toBeNull           'New prefix client'
      expect(@client2.settings.source)             .toBe 'browser',    'New prefix client'
      expect(@client2.settings.headers['X-FOO'])   .toBe 'bar',        'New prefix client'
      expect(@client2.settings.headers['X-FORK'])  .toBeUndefined      'New prefix client'

    it '#headers', ->
      @client2 = @client.headers({'X-BAR': 'foo'})
      expect(@client2.settings.endpoint)           .toBe '/original',  'New headers client'
      expect(@client2.settings.prefix)             .toBe 'foo',        'New headers client'
      expect(@client2.settings.metric)             .toBeNull           'New headers client'
      expect(@client2.settings.source)             .toBe 'browser',    'New headers client'
      expect(@client2.settings.headers['X-BAR'])   .toBe 'foo',        'New headers client'
      expect(@client2.settings.headers['X-FOO'])   .toBeUndefined      'New headers client'
      expect(@client2.settings.headers['X-FORK'])  .toBeUndefined      'New headers client'

    it '#endpoint', ->
      @client2 = @client.source('version')
      expect(@client2.settings.endpoint)           .toBe '/original',  'New source client'
      expect(@client2.settings.prefix)             .toBe 'foo',        'New source client'
      expect(@client2.settings.metric)             .toBeNull           'New source client'
      expect(@client2.settings.source)             .toBe 'version',    'New source client'
      expect(@client2.settings.headers['X-FOO'])   .toBe 'bar',        'New source client'
      expect(@client2.settings.headers['X-FORK'])  .toBeUndefined      'New source client'

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

    describe '#increment', ->
      it 'with args', ->
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

      it 'without args', ->
        @client.increment()

        expect(@client.send.args.length).toBe 1

        expect(@client.send.args[0][0].metric) .toBeUndefined()
        expect(@client.send.args[0][0].type)   .toBe 'increment'
        expect(@client.send.args[0][0].value)  .toBe 1
        expect(@client.send.args[0][0].source) .toBeUndefined()

    describe '#measure', ->
      it 'without metric', ->
        @client.measure 5
        @client.measure value: 3, source: 'bar'

        expect(@client.send.args.length).toBe 2

        expect(@client.send.args[0][0].metric) .toBeNull()
        expect(@client.send.args[0][0].type)   .toBe 'measure'
        expect(@client.send.args[0][0].value)  .toBe 5
        expect(@client.send.args[0][0].source) .toBeUndefined()

        expect(@client.send.args[1][0].metric) .toBeNull()
        expect(@client.send.args[1][0].type)   .toBe 'measure'
        expect(@client.send.args[1][0].value)  .toBe 3
        expect(@client.send.args[1][0].source) .toBe 'bar'

      it 'with metric', ->
        @client.measure 'foo', 5
        @client.measure 'foo', value: 3, source: 'bar'

        expect(@client.send.args.length).toBe 2

        expect(@client.send.args[0][0].metric) .toBe 'foo'
        expect(@client.send.args[0][0].type)   .toBe 'measure'
        expect(@client.send.args[0][0].value)  .toBe 5
        expect(@client.send.args[0][0].source) .toBeUndefined()

        expect(@client.send.args[1][0].metric) .toBe 'foo'
        expect(@client.send.args[1][0].type)   .toBe 'measure'
        expect(@client.send.args[1][0].value)  .toBe 3
        expect(@client.send.args[1][0].source) .toBe 'bar'

      it 'is curryable', ->
        client = @client.measure 'foo'

        client 5
        client value: 3, source: 'bar'

        expect(@client.send.args[0][0].metric) .toBe 'foo'
        expect(@client.send.args[0][0].type)   .toBe 'measure'
        expect(@client.send.args[0][0].value)  .toBe 5
        expect(@client.send.args[0][0].source) .toBeUndefined()

        expect(@client.send.args[1][0].metric) .toBe 'foo'
        expect(@client.send.args[1][0].type)   .toBe 'measure'
        expect(@client.send.args[1][0].value)  .toBe 3
        expect(@client.send.args[1][0].source) .toBe 'bar'

    describe '#timing', (done) ->

      it 'with options hash', ->
        @client.timing 'foo', 5
        @client.timing 'foo', value: 10, source: 'baz'

        expect(@client.send.args.length).toBe 2

        expect(@client.send.args[0][0].metric) .toBe 'foo'
        expect(@client.send.args[0][0].type)   .toBe 'timing'
        expect(@client.send.args[0][0].value)  .toBe 5
        expect(@client.send.args[0][0].source) .toBeUndefined()

        expect(@client.send.args[1][0].metric) .toBe 'foo'
        expect(@client.send.args[1][0].type)   .toBe 'timing'
        expect(@client.send.args[1][0].value)  .toBe 10
        expect(@client.send.args[1][0].source) .toBe 'baz'

      it 'async with metric', (done) ->
        timer = @client.timing 'async'

        setTimeout =>
          timer()
          expect(@client.send.args[0][0].metric) .toBe 'async'
          expect(@client.send.args[0][0].type)   .toBe 'timing'
          expect(@client.send.args[0][0].value)  .toBeGreaterThan 29
          expect(@client.send.args[0][0].source) .toBeUndefined()
          done()
        , 30

      it 'async with callback and metric', (done) ->
        @client.timing 'async', (d) =>
          setTimeout =>
            d()
            expect(@client.send.args[0][0].metric) .toBe 'async'
            expect(@client.send.args[0][0].type)   .toBe 'timing'
            expect(@client.send.args[0][0].value)  .toBeGreaterThan 29
            expect(@client.send.args[0][0].source) .toBeUndefined()
            done()
          , 30

      it 'async with callback only', (done) ->
        @client.timing (d) =>
          setTimeout =>
            d()
            expect(@client.send.args[0][0].metric) .toBeUndefined()
            expect(@client.send.args[0][0].type)   .toBe 'timing'
            expect(@client.send.args[0][0].value)  .toBeGreaterThan 29
            expect(@client.send.args[0][0].source) .toBeUndefined()
            done()
          , 30
