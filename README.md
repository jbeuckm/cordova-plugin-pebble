cordova-plugin-pebble
=====================

Implementation of the Pebble SDK for Cordova.

### Usage ###

From your project's root, add the plugin:

```cordova plugin add git@github.com:jbeuckm/cordova-plugin-pebble.git```

Set the UUID of your companion app, and register callbacks for connect/disconnect events from watches:

```javascript
window.plugins.Pebble.setAppUUID('<your-pebble-app-uuid>',
    function(event) {
        alert('watch connected');
    }
    function(event) {
        alert('watch disconnected');
    }
);
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

Launch your app:

```javascript
window.plugins.Pebble.launchApp(
    function(result){
        console.log(result);
    },
    function(err){
        alert(err);
    }
);
```

