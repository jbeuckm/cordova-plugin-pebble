
#import <Cordova/CDVPlugin.h>
#import <PebbleKit/PebbleKit.h>
#import "KBPebbleMessageQueue.h"

@interface Pebble : CDVPlugin <PBPebbleCentralDelegate>
{
    PBWatch *connectedWatch;
    KBPebbleMessageQueue *pebbleDataQueue;
}

@property (nonatomic, strong) NSString* connectCallbackId;
@property (nonatomic, strong) NSString* messageCallbackId;

@end
