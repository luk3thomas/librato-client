//= require ./utils
//= require ./userAgent
//
// Librato sources lets us create dynamic sources by using easy to read
// placeholders. e.g.
//   source: 'browser.version.platform'
//
// In the example above `browser`, `version`, and `platform` are replaced with
// information parsed from the userAgent string.
//
import { exists } from './utils.js';

class Sources {
  constructor() {
    this.userAgent = new Librato.UserAgent();

    // A map of custom args to tag names. Useful if you want to build the source
    // from information supplied in a callback. window.onerror is a good example
    // if we want to add the file name or error message to the source
    this.ARGS_MAP = {};

    // The custom placeholder tags
    this.TAGS = {
      page() {
        return this.pathname()
          .replace(/\/s\//,                     '')      // remove beginning /s/
          .replace(/^(\w+)s\/\d+\/?$/,          '$1')    // space  /s/spaces/1
          .replace(/^(\w+)s\/\d+\/(\w+)\/.+/,   '$1-$2') // explore  /s/spaces/1/explore/4
          .replace(/^(\w+)s\/.+/,               '$1')    // metric /s/metrics/foo
          .replace(/^([^\/]+).*/,               '$1')    // Keep first pathname, e.g. /s/public/adb3h32
          .replace(/\/$/,                       '');     // remove trailing slash
      },
      browser()  { return this.userAgent.parseUserAgent().browser; },
      version()  { return this.userAgent.parseUserAgent().version; },
      platform() { return this.userAgent.parseUserAgent().platform; },
    };
  }

  pathname() {
    return location.pathname;
  }

  // Creates a dynamic source from placeholder variables. e.g.
  //   source: 'browser.version.platform'
  // would become
  //   source: 'chrome.45.mac'
  createSource(placeholder, override) {
    if (!exists(override)) {
      return false;
    }
    return placeholder.split('.')
      .map((tag) => {
        const fn = this.TAGS[tag];
        let result;
        if (fn) {
          const args = this.ARGS_MAP[tag];
          if (this.ARGS_MAP[tag]) {
            result = fn.apply(this, args);
          } else {
            result = fn.call(this);
          }
        } else {
          result = tag;
        }
        return result;
      })
      .join('.')
      .slice(0, 255);
  }
}

export default Sources;
