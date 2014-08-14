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

@end
