var qrAuth = require('../index.js').auth,
    connect = require('connect'),
    http = require('http');

var keygen = function(username, callback) {
    var keys = {
        zenozeng: "private key"
    }
    callback(keys[username]);
}

var app = connect()
          .use(connect.cookieParser()) // required by session
          // When the user closes the browser the cookie (and session) will be removed.
          // As for chrome, you have to kill chrome, close window is not enough
          .use(connect.session({ secret: 'your sccret here', cookie: { maxAge: null }}))
          // parse body content
          .use(connect.urlencoded())
          .use(connect.json())
          .use(qrAuth({keygen: keygen}))
          .use(function(req, res) {
              res.end('Hello World!\n');
          });

http.createServer(app).listen(3000);