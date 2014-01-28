lm = require './login-manager.js'

module.exports = (req, res, keygen) ->
  res.writeHead 200, {'Content-Type': 'text/html'}
  {username, hash, sid, action} = req.body
  if hash? # login from api
    timestamp = parseInt((new Date().getTime()) / 1000 / 30)
    keygen username, (key) ->
      key = (new Buffer(key)).toString('hex')
      hmac = crypto.createHmac 'sha512', key
      hmac.setEncoding 'hex'
      hmac.write [username, sid, timestamp].join('')
      hmac.end()
      if hash is hmac.read()
        lm.login sid
        res.write JSON.stringify {status: "success"}
      else
        res.write JSON.stringify {status: "error", error: "hash not match"}
  else # login checker
    res.write JSON.stringify {login: lm.test(sid)}
  res.end()
