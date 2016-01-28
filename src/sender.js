import { post } from 'xhr';
import { extend, compact } from 'utils';
import Sources from 'sources';

class Sender {

  constructor(client) {
    this.client    = client;
    this.prefix    = client.settings.prefix;
    this.metric    = client.settings.metric;
    this.source    = client.settings.source;
    this.headers   = client.settings.headers;
    this.endpoint  = client.settings.endpoint;
    this.sources   = new Sources();
  }

  prepare(data) {
    data.metric = compact([this.prefix, this.metric, data.metric]).join('.');
    data.source = this.sources.createSource(this.source, data.source);
    return data;
  }

  send(data) {
    let json = JSON.stringify(this.prepare(data));
    post({ endpoint: this.endpoint
         , data: json
         , headers: extend({'Content-Type': 'application/json'}, this.headers) });
    return this.client;
  }
}

module.exports = Sender;
