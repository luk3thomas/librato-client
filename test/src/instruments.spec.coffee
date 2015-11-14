Instruments = require('../../src/instruments.coffee')
Promise = require('bluebird')
curry = require('curry')
sinon = require('sinon')

describe 'Instruments', ->

  beforeEach ->
    combine = (a, b) -> [a].concat([].slice.call(b))
    results = (v) -> v
    @sender =
      send: (v) -> v
    @instruments = new Instruments(@sender)
    sinon.spy(@instruments, 'instrument')
    @increment = -> @instruments.increment.apply(@instruments, arguments)
    @measure = -> @instruments.measure.apply(@instruments, arguments)
    @timing = -> @instruments.timing.apply(@instruments, arguments)
    @data = curry (type, opts) ->
      base =
        metric: 'foo'
        type: type
        source: undefined
        value: 99
      base[k] = v for k, v of opts
      base

  it '#increment', ->
    @incrementData = @data('increment')
    expect(@increment('foo'))               .toEqual @incrementData(value: 1), 'Default value'
    expect(@increment('foo', 5))            .toEqual @incrementData(value: 5), 'Specified value'
    expect(@increment('foo', value: 2, source: 'bar')).toEqual @incrementData(source: 'bar', value: 2)

  it '#measure', ->
    @measureData = @data('measure')
    expect(@measure('foo', 5))            .toEqual @measureData(value: 5),                'Specified value'
    expect(@measure('foo', source: 'bar')).toEqual @measureData(source: 'bar', value: 0), 'Default value'

    # Is curried
    @fooBazMeasure = @measure('fooBaz')
    expect(@fooBazMeasure(10))                      .toEqual @measureData(metric: 'fooBaz', value: 10)
    expect(@fooBazMeasure(source: 'bar', value: 10)).toEqual @measureData(metric: 'fooBaz', value: 10, source: 'bar')

  it '#timing', ->
    @timingData = @data('timing')
    expect(@timing('foo', 345)).toEqual @timingData(value: 345)

  it '#timing async returns the value', (done) ->
    timer = @timing('foobar')

    setTimeout ->
      data = timer(value: 100, source: 'baz', foo: 'bar')
      expect(data.value)  .toBe 100
      expect(data.source) .toBe 'baz'
      expect(data.foo)    .toBe 'bar'
      done()
    , 30

  it '#timing async with callback', (done) ->
    @timing 'foobar', (d) =>
      setTimeout =>
        d(source: 'foo', value: 1)
        [ type, metric, opts, value ] = @instruments.instrument.args[0]
        expect(type)   .toBe 'timing'
        expect(metric) .toBe 'foobar'
        expect(opts)   .toEqual {}
        expect(value)  .toBeGreaterThan 29
        done()
      , 30

  it '#timing async with callback and promise', (done) ->
    @timing 'foobar', (d) =>
      promise = new Promise (resolve, reject) ->
        resolve(200)

      promise
        .then d
        .then (v) ->
          expect(v).toBe 200, 'callback returns the original value'
        .then done
