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

    launchApp: function(success, failure) {

        // Ask cordova to execute a method on our FileWriter class
        cordova.exec(
            success,
            failure,
            'Pebble',
            'launchApp',
            [ ]
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
    }

};


module.exports = Pebble;
