XHR = require('../../src/xhr.coffee')

describe 'XHR', ->

  beforeEach ->
    sinon.stub(XHR, 'xhr').returns
      open: sinon.spy()
      send: sinon.spy()
      setRequestHeader: sinon.spy()

  afterEach ->
    XHR.xhr.restore()

  describe 'verb methods', ->

    beforeEach ->
      @data =
        endpoint: '/foo'
        headers: 'X-FOO': 'foo'

      @expectRequest = (type) ->
        switch type
          when 'POST'   then XHR.post(@data)
          when 'GET'    then XHR.get(@data)
          when 'PUT'    then XHR.put(@data)
          when 'DELETE' then XHR.delete(@data)
        [method, endpoint] = XHR.xhr().open.args[0]
        expect(type)    .toBe method, "method #{type}"
        expect(endpoint).toBe @data.endpoint, "method #{type}"

    it 'post',   -> @expectRequest('POST')
    it 'get',    -> @expectRequest('GET')
    it 'put',    -> @expectRequest('PUT')
    it 'delete', -> @expectRequest('DELETE')
