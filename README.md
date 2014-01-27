# QR-Auth

QR Code Based 2-Step Authentication

## Android

https://github.com/richard1122/QR-auth-android

## API

### Auth using phone

```
POST http://example.com {username: "username", hash: "hash", sid: "session id"}
```
```
success: {status: "success"}
```
```
error: {status: "error", error: "hash not match"}
```

## License

Licensed under the MIT License.

## Etc

The word "QR Code" is registered trademark of DENSO WAVE INCORPORATED
