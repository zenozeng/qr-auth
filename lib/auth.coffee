fs = require 'fs'
lm = require 'lib/login-manager.js'
apiHandle = require 'lib/auth-api.js'
yaqrcode = require 'yaqrcode'

module.exports = (options) ->
  {exclude, maxAge, keygen} = options
  # keygen should be a function which take username as arg
  # keygen = (username, callback) -> callback(key)
  (req, res, next) ->
    if exclude? and exclude.indexOf(req.url) > -1
      next()
    # login api
    if req.method is 'POST'
      apiHandle req, res, keygen
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
          html = html.replace(new RegExp('{{qrcode}}', 'g'), yaqrcode(json));
          res.write html
          res.end()

