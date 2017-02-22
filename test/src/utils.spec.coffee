Utils = require('src/utils')

describe 'Utils', ->

  beforeEach ->
    { @toArray
    , @compact
    , @isEmpty
    , @isFunction
    , @isNumber
    , @extend } = Utils

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

  it '#extend', ->
    a  = a: 1
    b  = b: 1
    c  = c: 1
    a2 = a: 2

    expect(@extend(a, b, c, a2)).toEqual a: 2, b: 1, c: 1
    expect(@extend(a2, b, c, a)).toEqual a: 1, b: 1, c: 1
    expect(a) .toEqual a: 1
    expect(b) .toEqual b: 1
    expect(c) .toEqual c: 1
    expect(a2).toEqual a: 2

    expect(@extend(a, b: 2)).toEqual a: 1, b: 2
