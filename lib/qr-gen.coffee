yaqrcode = require 'yaqrcode'

# options = {remote, username, key}
module.exports = (options) ->
  options.key = (new Buffer(options.key)).toString('hex')
  yaqrcode JSON.stringify options
