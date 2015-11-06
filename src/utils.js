function toArray(d) {
  return [].slice.call(d);
}

function exists(v) {
  return v === null || v === undefined;
}

export default {
  toArray,
  exists,
  compact: array => array.filter(v => exists(v)),
  isEmpty: object =>
    typeof object === 'object' && Object.keys(object).length === 0,
  isNumber: number =>
    typeof number === 'number' && !isNaN(number),
  combineArray: (...args) =>
    toArray(args).reduce((result, array) =>
      result.concat(toArray(array))
    , []),
};
