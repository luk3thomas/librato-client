const { extend } = require('./utils.coffee');

const send = function({endpoint, method, headers, data}) {
  const xhr = XHR.xhr();
  xhr.open(method, endpoint, true);
  for (let header in headers) {
    xhr.setRequestHeader(header, headers[header]);
  }
  xhr.send(data);
}

const XHR =
{ xhr:        () => new XMLHttpRequest()
, get:      opts => send(extend(opts, { method: 'GET' }))
, post:     opts => send(extend(opts, { method: 'POST' }))
, put:      opts => send(extend(opts, { method: 'PUT' }))
, 'delete': opts => send(extend(opts, { method: 'DELETE' }))
};

module.exports = XHR
