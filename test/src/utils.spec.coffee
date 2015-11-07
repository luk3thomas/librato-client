Utils = require('../../src/utils.coffee')
sinon = require('sinon')

describe 'Utils', ->

  beforeEach ->
    { @toArray,
      @compact,
      @curry,
      @isEmpty,
      @isFunction,
      @isNumber,
      @combineArray } = Utils

  it '#toArray', ->
    expect(@toArray(arguments)) .toEqual []
    expect(@toArray(true))      .toEqual []
    expect(@toArray({}))        .toEqual []
    expect(@toArray('a'))       .toEqual ['a']
    expect(@toArray(1))         .toEqual []

  it '#compact', ->
    expect(@compact([1, 2]))         .toEqual [1, 2]
    expect(@compact([1, 0]))         .toEqual [1, 0]
    expect(@compact([1, null]))      .toEqual [1]
    expect(@compact([1, undefined])) .toEqual [1]

  it '#curry', ->
    fn = @curry (a, b, c) -> a + b + c
    expect(fn(1, 2, 3)) .toBe 6
    expect(fn(1)(2, 3)) .toBe 6
    expect(fn(1)(2)(3)) .toBe 6
    expect(fn(1, 2)(3)) .toBe 6
    expect(fn(1)(2, 3)) .toBe 6

  it '#isEmpty', ->
    expect(@isEmpty({}))   .toBe true
    expect(@isEmpty([]))   .toBe true
    expect(@isEmpty(a: 1)) .toBe false
    expect(@isEmpty([1]))  .toBe false

  it '#isFunction', ->
    expect(@isFunction({}))   .toBe false
    expect(@isFunction([]))   .toBe false
    expect(@isFunction(a: 1)) .toBe false
    expect(@isFunction([1]))  .toBe false
    expect(@isFunction(->))   .toBe true

  it '#isNumber', ->
    expect(@isNumber(0))     .toBe true
    expect(@isNumber(1))     .toBe true
    expect(@isNumber(NaN))   .toBe false, 'NaN'
    expect(@isNumber(false)) .toBe false
    expect(@isNumber(true))  .toBe false
    expect(@isNumber({}))    .toBe false
    expect(@isNumber([]))    .toBe false

  it '#combineArray', ->
    expect(@combineArray([1], [2])).toEqual [1, 2]
