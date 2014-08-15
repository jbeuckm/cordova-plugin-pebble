
#import "Pebble.h"

@implementation Pebble

@synthesize connectCallbackId;
@synthesize messageCallbackId;

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
        pebbleDataQueue.watch = connectedWatch;
    }
    [self listenToConnectedWatch];
}


-(void)listenForMessages:(CDVInvokedUrlCommand *)command
{
    self.messageCallbackId = command.callbackId;
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
                    [NSNumber numberWithInt:(int)connected.count], @"count",
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

-(void)killApp:(CDVInvokedUrlCommand *)command
{
    if (![self checkWatchConnected]) return;

    NSLog(@"Pebble killApp()");

    [connectedWatch appMessagesKill:^(PBWatch *watch, NSError *error) {
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
            NSLog(@"error killing Pebble app");

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



-(void)sendMessage:(CDVInvokedUrlCommand *)command
{
    if (![self checkWatchConnected]) return;

    NSLog(@"Pebble sendMessage()");

    NSNumber *key = [command.arguments objectAtIndex:0];
    NSString *message = [command.arguments objectAtIndex:1];
    NSDictionary *update = [NSDictionary dictionaryWithObjectsAndKeys: message, key, nil];

    NSLog(@"Pebble SDK will send update %@", update);

    [connectedWatch appMessagesPushUpdate:update onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
        if (!error) {
            NSLog(@"Pebble: Successfully sent message.");
          NSDictionary *jsonObj = [ [NSDictionary alloc]
                                   initWithObjectsAndKeys :
                                   @"true", @"success",
                                   nil
                                   ];

          CDVPluginResult *pluginResult = [ CDVPluginResult
                                           resultWithStatus    : CDVCommandStatus_OK
                                           messageAsDictionary : jsonObj
                                           ];

          [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];        }

        else {
            NSLog(@"Pebble: Error sending message: %@", error);
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




-(void)sendImage:(CDVInvokedUrlCommand *)command
{
    if (![self checkWatchConnected]) return;

    NSLog(@"Pebble sendImage()");

    NSNumber *key = [command.arguments objectAtIndex:0];

    NSString *base64String = [command.arguments objectAtIndex:1];
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    UIImage *image = [UIImage imageWithData:data];

    [self sendImageToPebble:image withKey: key];

    NSLog(@"Pebble: back from sendImageToPebble");
}

#define MAX_OUTGOING_SIZE 95

-(void)sendImageToPebble:(UIImage*)image withKey:(id)key {

    uint8_t width = image.size.width;
    uint8_t height = image.size.height;
    NSLog(@"Pebble: sending image size %d x %d", width, height);

    PBBitmap* pbBitmap = [PBBitmap pebbleBitmapWithUIImage:image];
    size_t length = [pbBitmap.pixelData length];
    uint8_t j = 0;
    NSLog(@"length of the pixelData: %zu", length);
    for(size_t i = 0; i < length; i += MAX_OUTGOING_SIZE-3) {
        NSMutableData *outgoing = [[NSMutableData alloc] initWithCapacity:MAX_OUTGOING_SIZE];
        [outgoing appendBytes:&j length:1];
        [outgoing appendBytes:&width length:1];
        [outgoing appendBytes:&height length:1];
        [outgoing appendData:[pbBitmap.pixelData subdataWithRange:NSMakeRange(i, MIN(MAX_OUTGOING_SIZE-3, length - i))]];
        //enqueue ex: https://github.com/Katharine/peapod/
        [pebbleDataQueue enqueue:@{key: outgoing}];
        ++j;
        NSLog(@" --enqueued %lu bytes", MIN(MAX_OUTGOING_SIZE-3, length - i));
    }
}



-(BOOL)checkWatchConnected
{
    if (connectedWatch == nil) {

        NSLog(@"Pebble: No watch connected.");

        return FALSE;
    }
    else {
        return TRUE;
    }
}


#pragma mark utils

- (void)listenToConnectedWatch
{
    if (connectedWatch) {
        [connectedWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
            NSLog(@"Pebble: received message: %@", update);

            NSMutableDictionary* returnInfo = [[NSMutableDictionary alloc] init];
            [returnInfo setObject:[watch name] forKey:@"watch"];

            for (NSNumber *key in update) {
                [returnInfo setObject:[update objectForKey:key] forKey:[key stringValue]];
            }

            CDVPluginResult* result = nil;
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];
            [result setKeepCallbackAsBool:YES];

            [self.commandDelegate sendPluginResult:result callbackId:self.messageCallbackId];

            return YES;
        }];
    }
    else {
        NSLog(@"Pebble: Will not listen for messages: no watch connected.");
    }
}

- (void)pluginInitialize
{

    [[PBPebbleCentral defaultCentral] setDelegate:self];

    pebbleDataQueue = [[KBPebbleMessageQueue alloc] init];
}

#pragma mark delegate methods

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    NSLog(@"Pebble connected: %@", [watch name]);
    connectedWatch = watch;
    pebbleDataQueue.watch = connectedWatch;

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
