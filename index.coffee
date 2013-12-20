http = require 'http'
fs = require 'fs'
qrcode = require 'yaqrcode'
uuid = require 'node-uuid'
cookie = require 'cookie'
speakeasy = require 'speakeasy'
qs = require 'querystring'
crypto = require 'crypto'

fs.readFile 'config.json', (err, data) ->
  throw err if err
  config = JSON.parse data

  server = http.createServer (req, res) ->
    response = (title, body) ->
      res.writeHead 200, {'Content-Type': 'text/html'}
      html = '<style>body {padding: 100px; }
        h1 {font-weight: normal; border-bottom: 3px solid #ccc; font-size: 28px; color: #777; margin: 7px;}</style>'
      html += "<h1>#{title}</h1>#{body}"
      res.write html
      res.end()

    url = req.url
    if url is '/'
      isLogin = false
      if isLogin
        response 'Login Success!', ''
      else
        json =
          session: uuid.v1()
          remote: config.remote
        json = JSON.stringify(json)
        base64 = qrcode json
        response "AUTHORIZATION IS NEEDED TO ACCESS", "<img id='qr-code' src='#{base64}' alt='qr'/>"
    # api for android
    if url is '/auth'
      console.log req.method
      if req.method is 'POST'
        body = ''
        req.on 'data', (data) -> body += data
        req.on 'end', ->
          shasum = crypto.createHash 'sha1'
          shasum.update [username, config.users.zenozeng.key, session].join('')
          d = shasum.digest 'hex'

          POST = qs.parse body
          {username, hash, session} = POST
          console.log POST

          if hash is d
            
          else
            response
    if url is '/user/zenozeng'
      json =
        remote: config.remote
        username: "zenozeng"
        key: config.users.zenozeng.key
      base64 = qrcode JSON.stringify(json)
      response "SCAN THE QR CODE", "<img id='qr-code' src='#{base64}' alt='qr'/>"
  server.listen 8080, '0.0.0.0'
