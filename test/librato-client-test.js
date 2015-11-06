import { expect } from 'chai';
import LibratoClient from '../src/librato-client.js';

describe('LibratoClient', function() {
  const props = { endpoint: '/foo',
                  prefic: 'ui',
                  headers: { foo: 'bar' },
                  source: 'baz',
                  metric: 'qux' };

  beforeEach(function() {
    this.client = new LibratoClient();
  });

  describe('constructor', function() {
    it('initializes with defaults', function() {
      const { endpoint, prefix, headers, source, metric } = this.client.settings;
      expect(endpoint).to.equal('/');
      expect(prefix).to.equal('ui');
      expect(headers).to.deep.equal({});
      expect(source).to.equal('');
      expect(metric).to.equal('');
    });

    it('initializes with overrides', function() {
      const client = new LibratoClient({
        endpoint: '/foo',
        prefix: 'bar',
        headers: { foo: 'bar' },
        source: 'baz',
        metric: 'qux',
      });

      const { endpoint, prefix, headers, source, metric } = client.settings;
      expect(endpoint).to.equal('/foo');
      expect(prefix).to.equal('bar');
      expect(headers).to.deep.equal({foo: 'bar'});
      expect(source).to.equal('baz');
      expect(metric).to.equal('qux');
    });
  });

  describe('fork', function() {
    beforeEach(function() {
      this.client = new LibratoClient(props);
    });

    it('returns a new instance', function() {
      const forked = this.client.fork({ metric: 'boo' });
      expect(this.client).to.be.instanceof(LibratoClient);
      expect(forked)     .to.be.instanceof(LibratoClient);
      expect(forked).not.to.equal(this.client);

      expect(forked.settings.metric)     .to.equal('boo');
      expect(this.client.settings.metric).to.equal('qux');
    });
  });

  describe('forked methods', function() {
    it('endpoint', function() {
      expect(this.client.endpoint('test4').settings.endpoint).to.equal('test4');
    });

    it('prefix', function() {
      expect(this.client.prefix('test4').settings.prefix).to.equal('test4');
    });

    it('headers', function() {
      expect(this.client.headers('test4').settings.headers).to.equal('test4');
    });

    it('source', function() {
      expect(this.client.source('test4').settings.source).to.equal('test4');
    });

    it('metric', function() {
      expect(this.client.metric('test4').settings.metric).to.equal('test4');
    });
  });
});
