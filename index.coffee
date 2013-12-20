http = require 'http'
fs = require 'fs'
qrcode = require 'yaqrcode'
uuid = require 'node-uuid'
qs = require 'querystring'
crypto = require 'crypto'
Cookies = require 'cookies'
io = require 'socket.io'

loggedIn = {}

fs.readFile 'config.json', (err, data) ->
  throw err if err
  config = JSON.parse data

  server = http.createServer (req, res) ->
    cookies = new Cookies( req, res )
    expires = new Date()
    expires.setTime(expires.getTime() + 3600*10)
    session = cookies.get 'session-uuid', {expires: expires}
    unless session?
      console.log "NEW SESSION"
      session = uuid.v1()
      cookies.set 'session-uuid', session

    response = (title, body) ->
      res.writeHead 200, {'Content-Type': 'text/html'}
      html = '<style>body {padding: 100px; }
        h1 {font-weight: normal; border-bottom: 3px solid #ccc; font-size: 28px; color: #777; margin: 7px;}</style>'
      html += "<h1>#{title}</h1>#{body}"
      res.write html
      res.end()

    url = req.url

    if url is '/'
      console.log session
      console.log loggedIn
      console.log loggedIn[session]
      if loggedIn[session]? and loggedIn[session].timestamp < ((new Date()).getTime() - 10*3600)
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
          POST = qs.parse body
          {username, hash, session} = POST
          timestamp = parseInt((new Date().getTime()) / 1000 / 30)

          key = config.users.zenozeng.key
          hmac = crypto.createHmac 'sha512', key
          hmac.setEncoding 'hex'
          hmac.write [username, session, timestamp].join('')
          hmac.end()
          _hash = hmac.read()

          if hash is _hash
            # login
            console.log "Login Success: #{session}"
            loggedIn[session] = {timestamp: (new Date()).getTime(), username: username}
            msg = {status: 'success'}
            res.writeHead 200, {'Content-Type': 'text/html'}
            res.write JSON.stringify msg
            res.end()
          else
            console.log "Login Fail: #{session}"
            res.writeHead 200, {'Content-Type': 'text/html'}
            msg = {status: 'error', message: 'Login Fail'}
            res.write JSON.stringify msg
            res.end()

    if url is '/user/zenozeng'
      json =
        remote: config.remote
        username: "zenozeng"
        key: config.users.zenozeng.key
      base64 = qrcode JSON.stringify(json)
      response "SCAN THE QR CODE", "<img id='qr-code' src='#{base64}' alt='qr'/>"

  server.listen 8080, '0.0.0.0'
