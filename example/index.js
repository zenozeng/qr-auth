var qrAuth = require('../index.js'),
    connect = require('connect'),
    http = require('http');

var app = connect()
          .use(qrAuth())
          .use(function(req, res) {
              res.end('Hello World!\n');
          });

http.createServer(app).listen(3000);