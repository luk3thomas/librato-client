{ extend } = require('src/utils')

send = ({endpoint, method, headers, data}) ->
  xhr = XHR.xhr()
  xhr.open(method, endpoint, true)
  for header, value of headers
    xhr.setRequestHeader(header, value)
  xhr.send(data)

XHR =
  xhr: ->
    new XMLHttpRequest()

  post:   (opts) -> send(extend( method: 'POST',   opts ))
  get:    (opts) -> send(extend( method: 'GET',    opts ))
  put:    (opts) -> send(extend( method: 'PUT',    opts ))
  delete: (opts) -> send(extend( method: 'DELETE', opts ))

module.exports = XHR
