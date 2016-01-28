import UAParser from 'ua-parser-js'

const UserAgent = {
  getUA: () => { return navigator.userAgent; },

  normalizeName: (name) => {
    return (name || '')
      .replace(/\W/g, ' ')
      .trim()
      .split(' ')[0]
      .toLowerCase();
  },

  normalizeVersion: (version) => {
    return (version || '').split('.')[0]
  },

  // Returns the browser, version, and platform for a userAgent string.
  parseUserAgent: () => {
    const ua     = UserAgent.getUA();
    const result = new UAParser(ua).getResult();

    const browser  = (result.browser.name || '').toLowerCase();
    const version  = UserAgent.normalizeVersion(result.browser.version);
    const platform = UserAgent.normalizeName(result.os.name);

    return { browser, version, platform };
  }
}

module.exports = UserAgent;
