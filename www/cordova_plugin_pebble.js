var Pebble = {

    setAppUUID: function(uuid, connectCallback, disconnectCallback) {

        // Ask cordova to execute a method on our FileWriter class
        cordova.exec(
            connectCallback,
            disconnectCallback,
            'Pebble',
            'setAppUUID',
            [ uuid ]
        );

    },

    getVersionInfo: function(success, failure) {

        cordova.exec(
            success,
            failure,
            'Pebble',
            'getVersionInfo',
            []
        );
    },

    countConnectedWatches: function(success, failure) {

        cordova.exec(
            success,
            failure,
            'Pebble',
            'countConnectedWatches',
            []
        );
    },

    launchApp: function(success, failure) {

        // Ask cordova to execute a method on our FileWriter class
        cordova.exec(
            success,
            failure,
            'Pebble',
            'launchApp',
            [ ]
        );

    }

};


module.exports = Pebble;
