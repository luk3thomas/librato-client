function createRequest(type, metric, opts, defaultValue) {
  const { value = defaultValue, source } = opts;
  return { type, metric, source, value };
}

function toOptions(opts = {}) {
  let options = opts;
  if (isNumber(opts)) {
    options = { value: opts };
  }
  return options;
}

export default {
  increment(fn, metric, opts = {}) {
    return fn(...createRequest('increment', metric, toOptions(opts), 1));
  },

  measure(fn, metric, opts = {}) {
    return fn(...createRequest('measure', metric, toOptions(opts), 0));
  },

  timing(fn, metric, opts = {}) {
    // Pass timing as a callback
    if (isFunction(metric)) {
      const start    = +new Date();
      const callback = metric;
      const done = function() {
        const end = +new Date();
        return fn(...createRequest('timing', metric, toOptions(options), end - start));
      };
      return callback.call(null, done);
    } else if (isEmpty(opts) || isEmpty(metric)) {
      const start = +new Date();
      return function(options = {}) {
        const end = +new Date();
        return fn(...createRequest('timing', metric, toOptions(options), end - start));
      };
    }
  },
};
