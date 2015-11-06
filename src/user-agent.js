import UAParser from 'ua-parser-js';

class UserAgent {
  constructor(ua) {
    this.ua = ua;
    this.parser = new UAParser(ua);
  }

  // Need to set the UA string for testing
  setUA(ua) {
    this.parser.setUA(ua);
  }

  normalizeName(name) {
    return (name || '')
      .replace(/\W/g, ' ')
      .trim()
      .split(' ')[0]
      .toLowerCase();
  }

  normalizeVersion(version) {
    return (version || '').split('.')[0];
  }

  // Returns the browser, version, and platform for a userAgent string.
  parseUserAgent() {
    const result = this.parser.getResult();

    const browser  = (result.browser.name || '').toLowerCase();
    const version  = this.normalizeVersion(result.browser.version);
    const platform = this.normalizeName(result.os.name);

    return { browser, version, platform };
  }
}

export default UserAgent;
