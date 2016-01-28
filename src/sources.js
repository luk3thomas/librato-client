import { parseUserAgent } from 'user-agent'

class Sources {
  constructor() {
    this.TAGS =
    { browser:  () => { return parseUserAgent().browser; }
     ,version:  () => { return parseUserAgent().version; }
     ,platform: () => { return parseUserAgent().platform; } }
  }
  createSource(placeholder='', override) {
    if (override == null) {
      return placeholder
        .split('.')
        .map((tag) => {
          const fn = this.TAGS[tag]
          if (fn == null)
            return tag;
          else
            return fn.call(this);
        })
        .join('.')
        .slice(0, 255);
    } else {
      return override;
    }
  }
}

module.exports = Sources;
