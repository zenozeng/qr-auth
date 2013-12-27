http = require 'http'
fs = require 'fs'
qrcode = require 'yaqrcode'
uuid = require 'node-uuid'
qs = require 'querystring'
crypto = require 'crypto'
Cookies = require 'cookies'

loggedIn = {}

fs.exists 'config.json', (exists) ->

  # if config.json not exists
  # start init
  unless exists
    server = http.createServer (req, res) ->
      res.writeHead 200, {'Content-Type': 'text/html'}
      if req.method is 'POST'
        body = ''
        req.on 'data', (data) -> body += data
        req.on 'end', ->
          POST = qs.parse body
          str = "<style>
            body {font-size: 12px; word-break:break-all; padding: 2em;}
            pre {color: #777;}
            </style>"
          base64 = qrcode JSON.stringify(POST)
          str += "<body>
            <h1>Scan the QR Code below to add User to your Phone</h1>
            <pre>"
          str += JSON.stringify POST, null, "  "
          str += "</pre><br><img id='qr-code' src='#{base64}' alt='qr'/></body>"
          res.write str
          res.end()
          # TODO: write to config.json
      else
        fileStream = fs.createReadStream 'theme/init.html'
        fileStream.pipe res
    server.listen 8080, '0.0.0.0'

  # config.json exists
  else

    fs.readFile 'config.json', (err, data) ->
      throw err if err
      config = JSON.parse data

      server = http.createServer (req, res) ->
        cookies = new Cookies( req, res )
        expires = new Date()
        expires.setTime(expires.getTime() + 3600*10)
        session = cookies.get 'session-uuid', {expires: expires}
        unless session?
          session = uuid.v1()
          cookies.set 'session-uuid', session

        response = (title, body) ->
          res.writeHead 200, {'Content-Type': 'text/html'}
          html = '<style>body {padding: 100px; }
            h1 {font-weight: normal; border-bottom: 3px solid #ccc; font-size: 28px; color: #777; margin: 7px;}</style>'
          html += "<h1>#{title}</h1>#{body}"
          res.write html
          res.end()


        if loggedIn[session]? and loggedIn[session].timestamp < ((new Date()).getTime() - 10*3600)
          # logged in and ignore
          return

        if req.method is 'GET'
          json =
            session: uuid.v1()
            remote: config.remote
          json = JSON.stringify(json)
          base64 = qrcode json
          response "AUTHORIZATION IS NEEDED TO ACCESS", "<img id='qr-code' src='#{base64}' alt='qr'/>
            <form action='' method='post'><input type='text' name='action' value='clone'><input type='submit'></form>"

        if req.method is 'POST'
          body = ''
          req.on 'data', (data) -> body += data
          req.on 'end', ->
            POST = qs.parse body
            {username, hash, session, action} = POST

            console.log POST
            msg = {status: 'success'}
            res.writeHead 200, {'Content-Type': 'text/html'}
            res.write JSON.stringify msg
            res.end()

            if action is 'check'

              console.log {POST: POST}

            else if action is 'auth'

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

            else if action is 'clone'
              json =
                remote: config.remote
                username: "zenozeng"
                key: config.users.zenozeng.key
              base64 = qrcode JSON.stringify(json)
              response "SCAN THE QR CODE", "<img id='qr-code' src='#{base64}' alt='qr'/>"

      server.listen 8080, '0.0.0.0'
