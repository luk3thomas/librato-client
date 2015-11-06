import Instruments from './instruments.js';
import { compact } from './utils.js';

class LibratoClient {

  constructor(opts = {}) {
    const { endpoint = '/',
            prefix   = 'ui',
            headers  = {},
            source   = '',
            metric   = '' } = opts;
    this.settings = { endpoint, prefix, headers, source, metric };
  }

  // Creates a new copy of the client with updated settings
  fork(opts = {}) {
    return new LibratoClient({...this.settings, ...opts});
  }

  // Settings methods
  endpoint(endpoint) { return this.fork({ endpoint }); }
  prefix(prefix)     { return this.fork({ prefix }); }
  headers(headers)   { return this.fork({ headers }); }
  source(source)     { return this.fork({ source }); }
  metric(metric)     { return this.fork({ metric }); }


  // Instrumentation interface
  increment(...args) { return Instruments.increment(...[this.prepare, ...args]); }
  measure(...args)   { return Instruments.measure(...[this.prepare, ...args]); }
  timing(...args)    { return Instruments.timing(...[this.prepare, ...args]); }

  // Server communication interface
  prepare(data) {
    const { prefix, metric, source } = this.settings;

    data.metric = compact([prefix, metric, data.metric]).join('.');
    data.source = this.sources.createSource(source, data.source);
    return data;
  }

  send(data) {
    const { headers, endpoint } = this.settings;
    const xhr = this.xhr();
    const json = JSON.stringify(this.prepare(data));

    xhr.open('POST', endpoint, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    for (key of headers) {
      xhr.setRequestHeader(key, headers[key]);
    }
    xhr.send(json);
    return this;
  }

  xhr() {
    return new XMLHttpRequest();
  }
}

export default LibratoClient;
