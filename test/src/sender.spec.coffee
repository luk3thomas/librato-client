{ extend } = require('../../src/utils.coffee')
LibratoClient = require('../../src/librato-client.coffee')
Sender = require('../../src/sender.coffee')
XHR = require('../../src/xhr.js')
sinon = require('sinon/pkg/sinon')

describe 'Sender', ->
  beforeEach ->
    @sender = new Sender( settings: {})
    sinon.stub(XHR, 'xhr').returns
      open: sinon.spy()
      send: sinon.spy()
      setRequestHeader: sinon.spy()

  afterEach ->
    XHR.xhr.restore()

  it '#prepare', ->
    data =
      metric: 'foo'
      source: 'bar'
      value: 1
      type: 'increment'

    prepared = @sender.prepare(data)

    expect(prepared.metric) .toBe 'foo',       'Default options'
    expect(prepared.source) .toBe 'bar',       'Default options'
    expect(prepared.type)   .toBe 'increment', 'Default options'
    expect(prepared.value)  .toBe 1,           'Default options'

  it '#send', ->
    settings =
      endpoint: '/tmp'
      metric: 'bazzer'

    data =
      metric: 'foo'
      source: 'bar'
      value: 1
      type: 'increment'

    @sender = new Sender(new LibratoClient(settings))
    @sender.send(data)

    expect(XHR.xhr().open.args.length) .toBe 1
    expect(XHR.xhr().open.args[0][0])  .toBe 'POST'
    expect(XHR.xhr().open.args[0][1])  .toBe '/tmp'
    expect(XHR.xhr().open.args[0][2])  .toBe true

    expect(XHR.xhr().setRequestHeader.args.length) .toBe 1
    expect(XHR.xhr().setRequestHeader.args[0][0])  .toBe 'Content-Type'
    expect(XHR.xhr().setRequestHeader.args[0][1])  .toBe 'application/json'

    json = JSON.parse XHR.xhr().send.args[0][0]
    expect(json.metric) .toBe 'bazzer.foo', 'prepends base metric'
    expect(json.source) .toBe 'bar'
    expect(json.value)  .toBe 1
    expect(json.type)   .toBe 'increment'

    @sender = new Sender(new LibratoClient(extend(settings, headers: {'X-TOKEN': 'foo'})))
    @sender.send(data)

    expect(XHR.xhr().setRequestHeader.args.length) .toBe 3
    expect(XHR.xhr().setRequestHeader.args[1][0])  .toBe 'Content-Type',     'With custom headers'
    expect(XHR.xhr().setRequestHeader.args[1][1])  .toBe 'application/json', 'With custom headers'
    expect(XHR.xhr().setRequestHeader.args[2][0])  .toBe 'X-TOKEN',          'With custom headers'
    expect(XHR.xhr().setRequestHeader.args[2][1])  .toBe 'foo',              'With custom headers'

    expect(@sender.send(data) instanceof LibratoClient).toBe true, 'Chains to self'

