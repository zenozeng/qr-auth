# Login Manager

loggedIn = []

login = (sid, maxAge) ->
  now = (new Date()).getTime()
  sess = {sid: sid, expires: now + maxAge}
  loggedIn.push sess

test = (sid) ->
  # unset expired sess
  loggedIn = loggedIn.filter (elem) -> elem.expires > now
  matches = loggedIn.filter (elem) -> elem.sid is sid
  matches.length > 0

module.exports = {login: login, test: test}
