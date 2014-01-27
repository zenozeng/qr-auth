fs = require 'fs'

qrAuth = (options) ->
  {exclude} = options
  (req, res, next) ->
    console.log req
    next()

module.exports = qrAuth
