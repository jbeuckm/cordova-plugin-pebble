//
//  Pebble.m
//  PGPebble
//
//  Created by Major Innovator on 8/13/14.
//
//

#import "Pebble.h"

@implementation Pebble


-(void)setAppUUID:(CDVInvokedUrlCommand *)command
{
    NSString *uuidString = [command.arguments objectAtIndex:0];

    NSLog(@"PGPebble setAppUUID() with %@", uuidString);

    uuid_t myAppUUIDbytes;
    NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:uuidString];
    [myAppUUID getUUIDBytes:myAppUUIDbytes];
    NSLog(@"%@", myAppUUID);

    [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];

    NSDictionary *jsonObj = [ [NSDictionary alloc]
                             initWithObjectsAndKeys :
                             uuidString, @"uuid",
                             @"true", @"success",
                             nil
                             ];

    CDVPluginResult *pluginResult = [ CDVPluginResult
                                     resultWithStatus    : CDVCommandStatus_OK
                                     messageAsDictionary : jsonObj
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
                                           resultWithStatus    : CDVCommandStatus_OK
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


-(void)startup:(CDVInvokedUrlCommand *)command
{

    [[PBPebbleCentral defaultCentral] setDelegate:self];

    connectedWatch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];
    [connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
        NSLog(@"Received message: %@", update);
        return YES;
    }];

    pebbleDataQueue = [[KBPebbleMessageQueue alloc] init];
    pebbleDataQueue.watch = connectedWatch;
}

#pragma mark delegate methods

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSLog(@"Pebble connected: %@", [watch name]);
    connectedWatch = watch;

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[watch name],@"name",nil];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    NSLog(@"Pebble disconnected: %@", [watch name]);

    if (connectedWatch == watch || [watch isEqual:connectedWatch]) {
        connectedWatch = nil;
    }

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[watch name],@"name",nil];
}



@end
