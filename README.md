# QR-Auth

QR Code Based 2-Step Authentication

## Status

May be available in few days.

## Usage

### Options

#### exclude (optional)

An array of request.url, will pass directly when match.

#### maxAge (optional)

Max age for user logged in. Default is 60*1000

#### keygen

A function taking username as arg and callback a key

```
var keygen = function(username, callback) {
    // get key somewhere
    key = keys[username];
    callback(key);
}
```

#### template (optional)

A html String, and its substring `{{qrcode}}` will be replaced the base64 qrcode.

See template.html for example.

## Android

https://github.com/richard1122/QR-auth-android

## QR Auth API

### Auth

A JSON String after decode:

```
{
    sid: "the session of the remote connecter",
    remote: "the remote page for auth, http://example.com, for example."
}
```

When receive this message, you should 

```
POST remote {username: "username", hash: "hash", sid: "session id"}
```

Hash was generated by following code:

```
timestamp = parseInt((new Date().getTime()) / 1000 / 30)
hmac = crypto.createHmac 'sha512', key
hmac.setEncoding 'hex'
hmac.write [username, sid, timestamp].join('')
hmac.end()
hash = hmac.read()
```

Will receive:

```
success: {status: "success"}
```
```
error: {status: "error", error: "hash not match"}
```


### Add User

A JSON String after decode.

```
{
    remote: "the remote page for auth",
    username: "username",
    key: "user's private key, may be very long, in HEX"
}
```

You should save this in your database.

## License

Licensed under the MIT License.

## Etc

The word "QR Code" is registered trademark of DENSO WAVE INCORPORATED
