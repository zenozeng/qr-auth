fs = require 'fs'
lm = require 'lib/login-manager.js'
yaqrcode = require 'yaqrcode'

qrAuth = (options) ->
  {exclude, maxAge, keygen, url} = options
  # keygen should be a function which take username as arg
  # keygen = (username, callback) -> callback(key)
  (req, res, next) ->
    if exclude? and exclude.indexOf(req.url) > -1
      next()
    # login api
    if req.method is 'POST'
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
        {login: lm.test(sid)}
      res.end()
    else
      sid = req.sessionID
      if lm.test sid
        next()
      else
        res.writeHead 200, {'Content-Type': 'text/html'}
        fs.readFile "template.html", {encoding: 'UTF-8'}, (err, html) ->
          json =
            sid: sid
            remote: req.protocol + "://" + req.get('host') + req.url
          json = JSON.stringify(json)
          base64 = yaqrcode json
          html = html.replace(new RegExp('{{qrcode}}', 'g'), base64);
          res.write html
          res.end()

module.exports = qrAuth
