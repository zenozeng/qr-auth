qrEncoder = require('qr').Encoder

qr = (str) ->
  encoder = new qrEncoder
  encoder.on 'end', (buffer) ->
    console.log buffer
  encoder.encode str

