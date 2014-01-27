// Generated by CoffeeScript 1.6.3
(function() {
  var loggedIn, login, test;

  loggedIn = [];

  login = function(sid, maxAge) {
    var now, sess;
    now = (new Date()).getTime();
    sess = {
      sid: sid,
      expires: now + maxAge
    };
    return loggedIn.push(sess);
  };

  test = function(sid) {
    var matches;
    loggedIn = loggedIn.filter(function(elem) {
      return elem.expires > now;
    });
    matches = loggedIn.filter(function(elem) {
      return elem.sid === sid;
    });
    return matches.length > 0;
  };

  module.exports = {
    login: login,
    test: test
  };

}).call(this);