//
//  AdjustAdobeExtension.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 04/09/2020.
//

#import "AdjustAdobeExtension.h"
#import "AdjustAdobeExtensionSharedStateListener.h"
#import "AdjustAdobeExtensionEventListener.h"

NSString *const ADJAdobeAdjustEventToken = @"adj.eventToken";
NSString *const ADJAdobeAdjustEventCurrency = @"currency";
NSString *const ADJAdobeAdjustEventRevenue = @"revenue";

@implementation AdjustAdobeExtension

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSError* error = nil;
        
        // Shared State listener
        if ([self.api registerListener:[AdjustAdobeExtensionSharedStateListener class]
                             eventType:@"com.adobe.eventType.hub"
                           eventSource:@"com.adobe.eventSource.sharedState"
                                 error:&error]) {
            NSLog(@"AdjustAdobeExtensionSharedStateListener successfully registered for Event Hub Shared State events");
        } else if (error) {
            NSLog(@"An error occured while registering AdjustAdobeExtensionSharedStateListener, error code: %ld", [error code]);
        }
        
        if ([self.api registerListener:[AdjustAdobeExtensionEventListener class]
                             eventType:@"com.adobe.eventType.generic.track"
                           eventSource:@"com.adobe.eventSource.requestContent"
                                 error:&error]) {
            NSLog(@"AdjustAdobeExtensionSharedStateListener Analytics Events listener was registered");
        }
        else if (error) {
            NSLog(@"AdjustAdobeExtensionSharedStateListener Error while registering Analytics Events listener!!\n%@ %d", [error domain], (int)[error code]);
        }
        
    }
    return self;
}

- (void)handleEventData:(nullable NSDictionary *)eventData {
    if (eventData == nil) {
        return;
    }
    
    NSDictionary *contextdata = eventData[@"contextdata"];
    NSString *adjEventToken = contextdata[ADJAdobeAdjustEventToken];
    
    if (adjEventToken) {
        ADJEvent *event = [ADJEvent eventWithEventToken:adjEventToken];
        
        NSString *currency = contextdata[ADJAdobeAdjustEventCurrency];
        NSNumber *revenue = contextdata[ADJAdobeAdjustEventRevenue];
        
        if (currency && revenue) {
            [event setRevenue:[revenue doubleValue] currency:currency];
        }
        
        [Adjust trackEvent:event];
    }
}

+ (void)registerExtension {
    NSError *error = nil;
    if ([ACPCore registerExtension:[AdjustAdobeExtension class] error:&error]) {
        NSLog(@"AdjustExtension was registered");
    } else {
        NSLog(@"Error registering AdjustExtension: %@ %d", [error domain], (int)[error code]);
    }
}

- (nullable NSString*) name {
    return @"com.adjust.extension.adobe";
}

- (nullable NSString*) version {
    return [NSString stringWithFormat:@"Adjust SDK version %ld", (long)[Adjust version]];
}

@end
