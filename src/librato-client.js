import { post } from 'xhr';
import { extend } from 'utils';
import Sender from 'sender';
import Instruments from 'instruments';

class LibratoClient {

  constructor(opts={}) {
    const
    { endpoint = '/'
    , prefix   = null
    , headers  = {}
    , metric   = null
    , source   = null } = opts

    this.settings    = { endpoint, prefix, headers, metric, source };
    this.sender      = new Sender(this);
    this.instruments = new Instruments(this.sender);
  }

  // Fork methods for updating the client's settings
  fork(opts = {}) {
    return new LibratoClient(extend(this.settings, opts));
  }

  source   (source)   { return this.fork({ source }) }
  metric   (metric)   { return this.fork({ metric }) }
  prefix   (prefix)   { return this.fork({ prefix }) }
  headers  (headers)  { return this.fork({ headers }) }
  endpoint (endpoint) { return this.fork({ endpoint }) }

  // Instrumentation methods
  timing(...args)    { return this.instruments.timing.apply(this.instruments, args) }
  measure(...args)   { return this.instruments.measure.apply(this.instruments, args) }
  increment(...args) { return this.instruments.increment.apply(this.instruments, args) }
}

module.exports = LibratoClient
