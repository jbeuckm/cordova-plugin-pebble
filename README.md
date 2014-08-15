cordova-plugin-pebble
=====================

Implementation of the Pebble SDK for Cordova.

### Usage ###

Fromm your project's root, add the plugin:

```cordova plugin add git@github.com:jbeuckm/cordova-plugin-pebble.git```

Set the UUID of your companion app, and register callbacks for connect/disconnect events from watches:

```javascript
        function pebbleConnectCallback(e) {
            alert('connect');
        }
        function pebbleDisconnectCallback(e) {
            alert('disconnect');
        }
        window.plugins.Pebble.setAppUUID('28AF3DC7-E40D-490F-BEF2-29548C8B0601', pebbleConnectCallback, pebbleDisconnectCallback);
```

Get Pebble version info:

```javascript
window.plugins.Pebble.getVersionInfo(
    function(info){
        console.log(info);
    },
    function(err){
        alert(err);
    }
);
```



