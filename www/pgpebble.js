var Pebble = {

    setAppUUID: function(uuid, success, failure) {

        // Ask cordova to execute a method on our FileWriter class
        cordova.exec(
            success,
            failure,
            'Pebble',
            'setAppUUID',
            [ uuid ]
        );

    }

};


module.exports = Pebble;
