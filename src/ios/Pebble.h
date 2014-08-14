//
//  Pebble.h
//  PGPebble
//
//  Created by Major Innovator on 8/13/14.
//
//

#import <Cordova/CDVPlugin.h>
#import <PebbleKit/PebbleKit.h>


@interface Pebble : CDVPlugin
{
    PBWatch *connectedWatch;
}

// This will return the file contents in a JSON object via the getFileContents utility method
- (void) setAppUUID:(CDVInvokedUrlCommand *)command;

@end
