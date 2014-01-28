var qrGen = require('../index.js').gen,
    http = require('http');

var options = {
    remote: "http://localhost:3000/",
    username: "zenozeng",
    key: "private key"
}

http.createServer(function(req, res) {
    console.log(req);
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.write('<img id="qr-code" src="'+qrGen(options)+'" alt="qr-auth"/>');
    res.end();
}).listen(3001);