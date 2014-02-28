Wire          = require 'i2c'

DIRECTION_GPIOA = 0x0
DIRECTION_GPIOB = 0x1
TO_GPIOA        = 0x14
FROM_GPIOB      = 0x13	

class MCP23017

  address: 0x0
  oldGpioA: 0x0
  stateGpioB: 0x0

  constructor: (@address, @device = '/dev/i2c-1') ->
    @wire = new Wire(@address, device: @device)
    @_initGpioA()
    @_initGpioB()

  allOff: ->
    @_send TO_GPIOA, [hex]
  
  setGpioAPinValue: (pin, value) ->
    pinHexMask = Math.pow(2, pin)
    if value is 0
      if (@oldGpioA & pinHexMask) is pinHexMask
        setHex = @oldGpioA ^ pinHexMask
        @oldGpioA = setHex
        @_send TO_GPIOA, [setHex]
    if value is 1
      unless (@oldGpioA & pinHexMask) is pinHexMask
        setHex = @oldGpioA ^ pinHexMask
        @oldGpioA = setHex
        @_send TO_GPIOA, [setHex]
  
  getGpioBPinValue: (pin) ->
    pinHexMask = Math.pow(2, pin)
    if (@stateGpioB & pinHexMask) is pinHexMask
      1
    else 
      0

  _initGpioA: () ->
    @_send DIRECTION_GPIOA, [0x0]
    @_send TO_GPIOA, [0x0]
  
  _initGpioB: () ->
    @_send DIRECTION_GPIOB, [0xFF]
    @stateGpioB = (@_read FROM_GPIOB,1)[0]
    @_readGpioBContiuously()
  
  _readGpioBContiuously: () ->
    self = this
    setInterval (->
      self.stateGpioB = (self._read(FROM_GPIOB, 1))[0]
    ), 10

  _send: (cmd, values) ->
    @wire.writeBytes cmd, values, (err) ->
      console.log err if err isnt null

  _read: (cmd, length) ->
    @wire.readBytes cmd, length, (err,res) ->
      if err isnt null
        console.log err
      else
        res
      return      


module.exports = MCP23017
