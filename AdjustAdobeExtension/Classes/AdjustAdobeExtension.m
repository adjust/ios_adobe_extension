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
NSString * const ADJAdobeExtensionName = @"com.adjust.adobeextension";
NSString * const ADJAdobeExtensionSdkPrefix = @"adobe_ext1.0.4";
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
                         eventType:ADJAdobeEventTypeHub
                       eventSource:ADJAdobeEventSourceSharedState
                             error:&error]) {
        [ACPCore log:ACPMobileLogLevelDebug
                 tag:ADJAdobeExtensionLogTag
             message:@"Successfully registered Extension Listener for Event Hub Shared State events."];
    } else {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:
                      @"An error occured while registering Extension Listener"
                      " for Event Hub Shared State events. %@",
                      (error) ? [NSString stringWithFormat:@"Code: %ld, Domain: %@, Description: %@.", (long)error.code, error.domain, error.localizedDescription ] :
                      @"Unknown error."]];
    }

    if ([self.api registerListener:[AdjustAdobeExtensionEventListener class]
                         eventType:ADJAdobeEventTypeGenericTrack
                       eventSource:ADJAdobeEventSourceRequestContent
                             error:&error]) {
        [ACPCore log:ACPMobileLogLevelDebug
                 tag:ADJAdobeExtensionLogTag
             message:@"Successfully registered Extension Listener for Extension Request Content events"];
    } else {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:
                      @"An error occured while registering Extension Listener"
                      " for Extension Request Content events: %@",
                      (error) ? [NSString stringWithFormat:@"Code: %ld, Domain: %@, Description: %@.", (long)error.code, error.domain, error.localizedDescription ] :
                      @"Unknown error."]];
    }

    return self;
}

- (void)handleEventData:(nullable NSDictionary *)eventData {
    if (eventData == nil) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"Extension event error: eventData is nil!"];
        return;
    }
    
    NSDictionary *contextdata = eventData[@"contextdata"];
    if (contextdata == nil) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"Extension event error: contextdata is nil!"];
        return;
    }

    NSString *adjEventToken = contextdata[ADJAdobeAdjustEventToken];
    if (adjEventToken == nil) {
        return;
    }

    if (!self.sdkInitialized) {
        [self.receivedEvents addObject:eventData];
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
             message:@"Extension should be registered first!"];
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

    if (config == nil) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"AdjustExtension registration error: config is nil!"];
        return;
    }

    if (config.environment == nil || config.environment.length == 0) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"AdjustExtension registration error: Environment is empty! Use ADJEnvironmentSandbox or ADJEnvironmentProduction."];
        return;
    }

    NSError *error = nil;
    if ([ACPCore registerExtension:[AdjustAdobeExtension class] error:&error]) {
        [ACPCore log:ACPMobileLogLevelDebug
                 tag:ADJAdobeExtensionLogTag
             message:@"Successfully registered Adjust Extension"];
        _configInstance = config;
    } else {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
            // message:[NSString stringWithFormat:@"Error registering AdjustExtension: %@ %d",
             message:[NSString stringWithFormat:
                      @"An error occured while registering Adjust Extension: %@",
                      (error) ? [NSString stringWithFormat:@"Code: %ld, Domain: %@, Description: %@.", (long)error.code, error.domain, error.localizedDescription ] :
                      @"Unknown error."]];
    }
}

- (nullable NSString *)name {
    return ADJAdobeExtensionName;
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
