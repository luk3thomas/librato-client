const currify = (fn, args, remaining) => {
  if (remaining < 1)
    return fn.apply(null, args);

  return (...args2) => {
    return currify(fn, args.slice(0, fn.length - 1).concat(args2), remaining - args2.length)
  };
};

const curry = (fn) => {
  return (...args) => {
    return currify(fn, args, fn.length - args.length);
  };
};

const is = curry((type, item) => {
  return typeof item === type;
})

const blank = a => a == null

module.exports = {
  extend: (...objects) => {
    let result = {};
    for (let i = 0; i < objects.length; i++) {
      for (let k in objects[i]) {
        result[k] = objects[i][k];
      }
    }
    return result;
  },
  curry,
  blank,
  present: (...args) => { return !blank(...args); },
  compact: array => array.filter(v => v != null),
  // comparison
  isEmpty:  o => is('object', o) && Object.keys(o).length === 0,
  isNumber: n => is('number', n) && !isNaN(n),
  isString:      is('string'),
  isFunction:    is('function')
};

