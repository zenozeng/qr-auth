fs = require 'fs'
lm = require './login-manager.js'
apiHandle = require './auth-api.js'
yaqrcode = require 'yaqrcode'

module.exports = (options) ->
  {exclude, maxAge, keygen, template} = options
  maxAge = 60*1000 unless maxAge?
  unless template?
    template = fs.readFileSync "../template.html", {encoding: 'UTF-8'}

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
        if req.headers["X-Forwarded-Protocol"] && req.headers["X-Forwarded-Protocol"] is 'https'
          protocol = 'https'
        else
          protocol = 'http'
        json =
          sid: sid
          remote: protocol + "://" + req.headers.host + req.url
        json = JSON.stringify(json)
        res.write template.replace(new RegExp('{{qrcode}}', 'g'), yaqrcode(json));
        res.end()
