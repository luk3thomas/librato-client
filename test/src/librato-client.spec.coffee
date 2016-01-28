LibratoClient = require('librato-client')
Promise = require('bluebird')
XHR = require('xhr.js')
sinon = require('sinon/pkg/sinon')

describe 'LibratoClient', ->
  beforeEach ->
    sinon.stub(XHR, 'xhr').returns
      open: sinon.spy()
      send: sinon.spy()
      setRequestHeader: sinon.spy()
    @client = new LibratoClient()

  afterEach ->
    XHR.xhr.restore()

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

    expect(@client2).not                        .toBe @client,      'Forked client'
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

  describe 'instrumentation', ->
    beforeEach ->
      sinon.stub(@client.sender, 'send')

    describe '#increment', ->
      it 'with args', ->
        @client.increment 'foo'
        @client.increment 'foo', 5
        @client.increment 'foo', source: 'bar', value: 5

        expect(@client.sender.send.args.length).toBe 3

        { metric, type, value, source } = @client.sender.send.args[0][0]
        expect(metric) .toBe 'foo'
        expect(type)   .toBe 'increment'
        expect(value)  .toBe 1
        expect(source) .toBeUndefined()

        { metric, type, value, source } = @client.sender.send.args[1][0]
        expect(metric) .toBe 'foo'
        expect(type)   .toBe 'increment'
        expect(value)  .toBe 5
        expect(source) .toBeUndefined()

        { metric, type, value, source } = @client.sender.send.args[2][0]
        expect(metric) .toBe 'foo'
        expect(type)   .toBe 'increment'
        expect(value)  .toBe 5
        expect(source) .toBe 'bar'

      it 'without args', ->
        @client.increment()

        expect(@client.sender.send.args.length).toBe 1

        { metric, type, value, source } = @client.sender.send.args[0][0]
        expect(metric) .toBeUndefined()
        expect(type)   .toBe 'increment'
        expect(value)  .toBe 1
        expect(source) .toBeUndefined()

    describe '#measure', ->
      it 'without metric', ->
        @client.measure 5
        @client.measure value: 3, source: 'bar'

        expect(@client.sender.send.args.length).toBe 2

        { metric, type, value, source } = @client.sender.send.args[0][0]
        expect(metric) .toBeNull()
        expect(type)   .toBe 'measure'
        expect(value)  .toBe 5
        expect(source) .toBeUndefined()

        { metric, type, value, source } = @client.sender.send.args[1][0]
        expect(metric) .toBeNull()
        expect(type)   .toBe 'measure'
        expect(value)  .toBe 3
        expect(source) .toBe 'bar'

      it 'with metric', ->
        @client.measure 'foo', 5
        @client.measure 'foo', value: 3, source: 'bar'

        expect(@client.sender.send.args.length).toBe 2

        { metric, type, value, source } = @client.sender.send.args[0][0]
        expect(metric) .toBe 'foo'
        expect(type)   .toBe 'measure'
        expect(value)  .toBe 5
        expect(source) .toBeUndefined()

        { metric, type, value, source } = @client.sender.send.args[1][0]
        expect(metric) .toBe 'foo'
        expect(type)   .toBe 'measure'
        expect(value)  .toBe 3
        expect(source) .toBe 'bar'

      it 'is curryable', ->
        client = @client.measure 'foo'

        client 5
        client value: 3, source: 'bar'

        { metric, type, value, source } = @client.sender.send.args[0][0]
        expect(metric) .toBe 'foo'
        expect(type)   .toBe 'measure'
        expect(value)  .toBe 5
        expect(source) .toBeUndefined()

        { metric, type, value, source } = @client.sender.send.args[1][0]
        expect(metric) .toBe 'foo'
        expect(type)   .toBe 'measure'
        expect(value)  .toBe 3
        expect(source) .toBe 'bar'

    describe '#timing', (done) ->

      it 'with options hash', ->
        @client.timing 'foo', 5
        @client.timing 'foo', value: 10, source: 'baz'

        expect(@client.sender.send.args.length).toBe 2

        { metric, type, value, source } = @client.sender.send.args[0][0]
        expect(metric) .toBe 'foo'
        expect(type)   .toBe 'timing'
        expect(value)  .toBe 5
        expect(source) .toBeUndefined()

        { metric, type, value, source } = @client.sender.send.args[1][0]
        expect(metric) .toBe 'foo'
        expect(type)   .toBe 'timing'
        expect(value)  .toBe 10
        expect(source) .toBe 'baz'

      it 'async with metric', (done) ->
        timer = @client.timing 'async'

        setTimeout =>
          timer()
          { metric, type, value, source } = @client.sender.send.args[0][0]
          expect(metric) .toBe 'async'
          expect(type)   .toBe 'timing'
          expect(value)  .toBeGreaterThan 29
          expect(source) .toBeUndefined()
          done()
        , 30

      it 'async with metric and source and value', (done) ->
        timer = @client.timing 'async'

        setTimeout =>
          timer({ source: 'bar', value: 400 })
          { metric, type, value, source } = @client.sender.send.args[0][0]
          expect(metric) .toBe 'async'
          expect(type)   .toBe 'timing'
          expect(value)  .not.toBe 400
          expect(source) .not.toBe 'bar'
          done()
        , 30

      it 'works with promises', (done) ->
        timer = @client.timing 'async'

        promise = new Promise (resolve, reject) ->
          resolve(20)

        promise
          .then(timer)
          .then (number) =>
            expect(number).toBe 20
            { metric, type, value, source } = @client.sender.send.args[0][0]
            expect(metric) .toBe 'async'
            expect(type)   .toBe 'timing'
            expect(value)  .toBeLessThan 20
            expect(source) .toBeUndefined()
            done()

      it 'async with callback and metric', (done) ->
        @client.timing 'async', (d) =>
          setTimeout =>
            d()
            { metric, type, value, source } = @client.sender.send.args[0][0]
            expect(metric) .toBe 'async'
            expect(type)   .toBe 'timing'
            expect(value)  .toBeGreaterThan 29
            expect(source) .toBeUndefined()
            done()
          , 30

      it 'async with callback only', (done) ->
        @client.timing (d) =>
          setTimeout =>
            d()
            { metric, type, value, source } = @client.sender.send.args[0][0]
            expect(metric) .toBeUndefined()
            expect(type)   .toBe 'timing'
            expect(value)  .toBeGreaterThan 29
            expect(source) .toBeUndefined()
            done()
          , 30
