//
//  Pebble.m
//  PGPebble
//
//  Created by Major Innovator on 8/13/14.
//
//

#import "Pebble.h"

@implementation Pebble

@synthesize connectCallbackId;

-(void)setAppUUID:(CDVInvokedUrlCommand *)command
{
    self.connectCallbackId = command.callbackId;

    NSString *uuidString = [command.arguments objectAtIndex:0];

    NSLog(@"PGPebble setAppUUID() with %@", uuidString);

    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    NSLog(@"%@", myAppUUID);

    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];

    NSArray *connected = [[PBPebbleCentral defaultCentral] connectedWatches];
    if (connected.count > 0) {
        NSLog(@"Pebble watch found at startup");
        connectedWatch = [connected objectAtIndex:0];
    }
    [self listenToConnectedWatch];
}


-(void)getVersionInfo:(CDVInvokedUrlCommand *)command
{
    if (![self checkWatchConnected]) return;

    NSLog(@"Pebble getVersionInfo()");

    [connectedWatch getVersionInfo:^(PBWatch *watch, PBVersionInfo *versionInfo ) {

        NSLog(@"Pebble firmware os version: %li", (long)versionInfo.runningFirmwareMetadata.version.os);
        NSLog(@"Pebble firmware major version: %li", (long)versionInfo.runningFirmwareMetadata.version.major);
        NSLog(@"Pebble firmware minor version: %li", (long)versionInfo.runningFirmwareMetadata.version.minor);
        NSLog(@"Pebble firmware suffix version: %@", versionInfo.runningFirmwareMetadata.version.suffix);

            NSDictionary *versionInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%li", (long)versionInfo.runningFirmwareMetadata.version.os], @"os",
                    [NSString stringWithFormat:@"%li", (long)versionInfo.runningFirmwareMetadata.version.major], @"major",
                    [NSString stringWithFormat:@"%li", (long)versionInfo.runningFirmwareMetadata.version.minor], @"minor",
                    versionInfo.runningFirmwareMetadata.version.suffix, @"suffix",
                    nil];

          CDVPluginResult *pluginResult = [ CDVPluginResult
                                           resultWithStatus    : CDVCommandStatus_OK
                                           messageAsDictionary : versionInfoDict
                                           ];

          [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    }
            onTimeout:^(PBWatch *watch) {
                NSLog(@"[INFO] Timed out trying to get version info from Pebble.");
    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_ERROR
                                     ];

          [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
     ];

}


-(void)countConnectedWatches:(CDVInvokedUrlCommand *)command
{
    NSArray *connected = [[PBPebbleCentral defaultCentral] connectedWatches];

            NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSString stringWithFormat:@"%i", (int)connected.count], @"count",
                    nil];

          CDVPluginResult *pluginResult = [ CDVPluginResult
                                           resultWithStatus    : CDVCommandStatus_OK
                                           messageAsDictionary : resultDict
                                           ];

          [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void)launchApp:(CDVInvokedUrlCommand *)command
{
    if (![self checkWatchConnected]) return;

    @synchronized(connectedWatch){

    NSLog(@"Pebble launchApp()");

    [connectedWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
        if (!error) {
          NSDictionary *jsonObj = [ [NSDictionary alloc]
                                   initWithObjectsAndKeys :
                                   @"true", @"success",
                                   nil
                                   ];

          CDVPluginResult *pluginResult = [ CDVPluginResult
                                           resultWithStatus    : CDVCommandStatus_OK
                                           messageAsDictionary : jsonObj
                                           ];

          [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        }
        else {
            NSLog(@"error launching Pebble app");

          NSDictionary *jsonObj = [ [NSDictionary alloc]
                                   initWithObjectsAndKeys :
                                   @"false", @"success",
                                   nil
                                   ];

          CDVPluginResult *pluginResult = [ CDVPluginResult
                                           resultWithStatus    : CDVCommandStatus_ERROR
                                           messageAsDictionary : jsonObj
                                           ];

          [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        }
    }];

    }
}


-(BOOL)checkWatchConnected
{
    if (connectedWatch == nil) {

        NSLog(@"[ERROR] No Pebble watch connected.");

        return FALSE;
    }
    else {
        return TRUE;
    }
}

- (void)listenToConnectedWatch
{
    if (connectedWatch) {
        [connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
            NSLog(@"[INFO] Received message: %@", update);
//            [self fireEvent:@"update" withObject:@{ @"message": update[MESSAGE_KEY] }];

    NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [returnInfo setObject:[connectedWatch name] forKey:@"name"];

    // Build a resultset for javascript callback.
    CDVPluginResult* result = nil;

    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.connectCallbackId];

            return YES;
        }];
    }
    else {
        NSLog(@"[ERROR] Will not listen for messages: no watch connected.");
    }
}

- (void)pluginInitialize
{
  NSLog(@"pebble init");

    [[PBPebbleCentral defaultCentral] setDelegate:self];

    /*
    connectedWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    [connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
        NSLog(@"Received message: %@", update);
        return YES;
    }];
    */

    pebbleDataQueue = [[KBPebbleMessageQueue alloc] init];
    pebbleDataQueue.watch = connectedWatch;
}

#pragma mark delegate methods

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSLog(@"Pebble connected: %@", [watch name]);
    connectedWatch = watch;
    [self listenToConnectedWatch];

    NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [returnInfo setObject:[watch name] forKey:@"name"];

    // Build a resultset for javascript callback.
    CDVPluginResult* result = nil;

    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.connectCallbackId];
}


- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Pebble disconnected: %@", [watch name]);

    if (connectedWatch == watch || [watch isEqual:connectedWatch]) {
        connectedWatch = nil;
    }

    NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    [returnInfo setObject:[watch name] forKey:@"name"];

    // Build a resultset for javascript callback.
    CDVPluginResult* result = nil;

    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:returnInfo];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult:result callbackId:self.connectCallbackId];
}



@end
