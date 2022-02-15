//
//  AdjustAdobeExtension.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 09/04/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import "AdjustAdobeExtension.h"
#import "AdjustAdobeExtensionSharedStateListener.h"
#import "AdjustAdobeExtensionEventListener.h"

NSString * const ADJAdobeExtensionLogTag = @"AdjustAdobeExtension";
NSString * const ADJAdobeExtensionSdkPrefix = @"adobe_ext1.0.3";

NSString * const ADJAdobeAdjustEventToken = @"adj.eventToken";
NSString * const ADJAdobeAdjustEventCurrency = @"adj.currency";
NSString * const ADJAdobeAdjustEventRevenue = @"adj.revenue";

static AdjustAdobeExtensionConfig *_configInstance = nil;

@interface AdjustAdobeExtension()

@property (nonatomic, assign) BOOL sdkInitialized;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *receivedEvents;

@end

@implementation AdjustAdobeExtension

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
        
    _sdkInitialized = NO;
    _receivedEvents = [NSMutableArray array];

    NSError *error = nil;

    // Shared State listener
    if ([self.api registerListener:[AdjustAdobeExtensionSharedStateListener class]
                         eventType:@"com.adobe.eventType.hub"
                       eventSource:@"com.adobe.eventSource.sharedState"
                             error:&error]) {
        [ACPCore log:ACPMobileLogLevelDebug tag:ADJAdobeExtensionLogTag
             message:@"successfully registered for Event Hub Shared State events"];
    } else if (error) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:
                      @"An error occured while"
                      " registering AdjustAdobeExtensionSharedStateListener, error code: %ld",
                      (long)[error code]]];
    } else {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:
                      @"An error occured while"
                      " registering AdjustAdobeExtensionSharedStateListener, without error code"]];
    }

    if ([self.api registerListener:[AdjustAdobeExtensionEventListener class]
                         eventType:@"com.adobe.eventType.generic.track"
                       eventSource:@"com.adobe.eventSource.requestContent"
                             error:&error]) {
        [ACPCore log:ACPMobileLogLevelDebug tag:ADJAdobeExtensionLogTag
             message:@"Successfully registered for Extension Request Content events"];
    } else if (error) {
        [ACPCore log:ACPMobileLogLevelError tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:
                      @"There was an error registering ExtensionListener"
                      " for Extension Request Content events: %@",
                      error.localizedDescription ?: @"unknown"]];
    } else {
        [ACPCore log:ACPMobileLogLevelError tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:
                      @"There was an error registering ExtensionListener"
                      " for Extension Request Content events, without error code"]];
    }

    return self;
}

- (void)handleEventData:(nullable NSDictionary *)eventData {
    if (eventData == nil) {
        return;
    }
    
    if (!self.sdkInitialized) {
        [self.receivedEvents addObject:eventData];
        return;
    }
    
    NSDictionary *contextdata = eventData[@"contextdata"];
    if (contextdata == nil) {
        return;
    }

    NSString *adjEventToken = contextdata[ADJAdobeAdjustEventToken];

    if (adjEventToken == nil) {
        return;
    }

    ADJEvent *event = [ADJEvent eventWithEventToken:adjEventToken];
    NSString *currency = contextdata[ADJAdobeAdjustEventCurrency];
    NSNumber *revenue = contextdata[ADJAdobeAdjustEventRevenue];

    if (currency && revenue) {
        [event setRevenue:[revenue doubleValue] currency:currency];
    }

    [Adjust trackEvent:event];
}

- (void)setupAdjustWithAppToken:(NSString *)appToken trackAttribution:(BOOL)trackAttribution {
    if (!_configInstance) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"Extension should be registered first"];
        return;
    }

    if (self.sdkInitialized) {
        return;
    }

    _configInstance.shouldTrackAttribution = trackAttribution;

    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken
                                                environment:_configInstance.environment];
    [adjustConfig setSdkPrefix:ADJAdobeExtensionSdkPrefix];
    [adjustConfig setDelegate:self];

    switch ([ACPCore logLevel]) {
        case ACPMobileLogLevelError:
            [adjustConfig setLogLevel:ADJLogLevelError];
            break;
        case ACPMobileLogLevelWarning:
            [adjustConfig setLogLevel:ADJLogLevelWarn];
            break;
        case ACPMobileLogLevelDebug:
            [adjustConfig setLogLevel:ADJLogLevelDebug];
            break;
        case ACPMobileLogLevelVerbose:
            [adjustConfig setLogLevel:ADJLogLevelVerbose];
            break;
    }

    [Adjust appDidLaunch:adjustConfig];

    self.sdkInitialized = YES;
    [self dumpReceivedEvents];
}

- (void)dumpReceivedEvents {
    if (self.receivedEvents.count <= 0) {
        return;
    }

    // dump events received before initialization
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (NSDictionary *event in self.receivedEvents) {
            [self handleEventData:event];
        }
        [self.receivedEvents removeAllObjects];
    });
}

+ (void)registerExtensionWithConfig:(AdjustAdobeExtensionConfig *)config {
    NSError *error = nil;
    if ([ACPCore registerExtension:[AdjustAdobeExtension class] error:&error]) {
        [ACPCore log:ACPMobileLogLevelDebug tag:ADJAdobeExtensionLogTag
             message:@"Successfully registered AdjustExtension"];
        _configInstance = config;
    } else if (error) {
        [ACPCore log:ACPMobileLogLevelError tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:@"Error registering AdjustExtension: %@ %d",
                      [error domain], (int)[error code]]];
    } else {
        [ACPCore log:ACPMobileLogLevelError tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:@"Error registering AdjustExtension, without error code"]];
    }
}

- (nullable NSString *)name {
    return @"com.adjust.adobeextension";
}

- (nullable NSString *)version {
    return [NSString stringWithFormat:@"%@%@", ADJAdobeExtensionSdkPrefix, [Adjust sdkVersion]];
}

#pragma mark - Adjust delegate

- (void)adjustAttributionChanged:(nullable ADJAttribution *)attribution {
    if (_configInstance.shouldTrackAttribution) {
        NSMutableDictionary *adjustData = [NSMutableDictionary dictionary];

        if (attribution.network != nil) {
            [adjustData setObject:attribution.network forKey:@"Adjust Network"];
        }
        if (attribution.campaign != nil) {
            [adjustData setObject:attribution.campaign forKey:@"Adjust Campaign"];
        }
        if (attribution.adgroup != nil) {
            [adjustData setObject:attribution.adgroup forKey:@"Adjust AdGroup"];
        }
        if (attribution.creative != nil) {
            [adjustData setObject:attribution.creative forKey:@"Adjust Creative"];
        }

        [ACPCore trackAction:@"Adjust Campaign Data Received"
                        data:adjustData];
    }

    if (_configInstance.attributionChangedBlock) {
        _configInstance.attributionChangedBlock(attribution);
    }
}

- (BOOL)adjustDeeplinkResponse:(nullable NSURL *)deeplink {
    if (_configInstance.deeplinkResponseBlock) {
        return _configInstance.deeplinkResponseBlock(deeplink);
    }

    return YES;
}

@end
