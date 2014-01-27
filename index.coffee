fs = require 'fs'

loggedIn = []

login = (sid, maxAge) ->
  now = (new Date()).getTime()
  sess = {sid: sid, expires: now + maxAge}
  loggedIn.push sess

isLogin = (sid) ->
  # unset expired sess
  loggedIn = loggedIn.filter (elem) -> elem.expires > now
  matches = loggedIn.filter (elem) -> elem.sid is sid
  matches.length > 0

qrAuth = (options) ->
  {exclude, maxAge} = options
  (req, res, next) ->
    sid = req.sessionID
    if isLogin sid
      next()
    else
      login sid, maxAge

module.exports = qrAuth
