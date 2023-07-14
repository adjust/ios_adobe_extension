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
NSString * const ADJAdobeExtensionSdkPrefix = @"adobe_ext1.1.1";
NSString * const ADJAdobeEventDataKeyAction = @"action";
NSString * const ADJAdobeEventDataKeyContextData = @"contextdata";

// Action types
NSString * const ADJAdobeAdjustActionTrackEvent = @"adj.trackEvent";
NSString * const ADJAdobeAdjustActionSetPushToken = @"adj.setPushToken";

// Adjust Event
NSString * const ADJAdobeAdjustEventToken = @"adj.eventToken";
NSString * const ADJAdobeAdjustEventCurrency = @"adj.currency";
NSString * const ADJAdobeAdjustEventRevenue = @"adj.revenue";
NSString * const ADJAdobeAdjustEventCallbackParamPrefix = @"adj.event.callback.";
NSString * const ADJAdobeAdjustEventPartnerParamPrefix = @"adj.event.partner.";

// Push token
NSString * const ADJAdobeAdjustPushToken = @"adj.pushToken";

char * const kQUEUE_ID_SYNC = "com.adjust.AdjustAdobeExtension.sync_queue";
static AdjustAdobeExtensionConfig *_configInstance = nil;

@interface AdjustAdobeExtension()

@property (nonatomic, assign) BOOL sdkInitialized;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *receivedEvents;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic,strong) NSNumber *numNan;
@property (nonatomic,strong) NSNumber *numPlusInf;
@property (nonatomic,strong) NSNumber *numMinusInf;

@end

@implementation AdjustAdobeExtension

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
             message:[NSString stringWithFormat:
                      @"An error occured while registering Adjust Extension: %@",
                      (error) ? [NSString stringWithFormat:@"Code: %ld, Domain: %@, Description: %@.", (long)error.code, error.domain, error.localizedDescription ] :
                      @"Unknown error."]];
    }
}

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
        
    _sdkInitialized = NO;
    _receivedEvents = [NSMutableArray array];
    _syncQueue = dispatch_queue_create(kQUEUE_ID_SYNC, DISPATCH_QUEUE_SERIAL);

    double dblZero = 0.0;
    double dblPlusOne = 1.0;
    double dblMinusOne = -1.0;
    _numPlusInf = [NSNumber numberWithDouble:dblPlusOne/dblZero];
    _numMinusInf = [NSNumber numberWithDouble:dblMinusOne/dblZero];
    _numNan = [NSNumber numberWithDouble:sqrt(dblMinusOne)];

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

    // Events listener
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

- (void)setupAdjustWithAppToken:(NSString *)appToken trackAttribution:(BOOL)trackAttribution {
    dispatch_async(self.syncQueue, ^{
        if (!_configInstance) {
            [ACPCore log:ACPMobileLogLevelError
                     tag:ADJAdobeExtensionLogTag
                 message:@"Extension should be registered first!"];
            return;
        }

        if (self.sdkInitialized == YES) {
            return;
        }

        self.sdkInitialized = YES;

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

        for (NSDictionary *event in self.receivedEvents) {
            [self processEvent:event];
        }
        [self.receivedEvents removeAllObjects];
    });
}

- (void)handleEventData:(nullable NSDictionary *)eventData {
    dispatch_async(self.syncQueue, ^{
        if (!self.sdkInitialized) {
            [self.receivedEvents addObject:eventData];
        } else {
            [self processEvent:eventData];
        }
    });
}

- (void)processEvent:(nullable NSDictionary *)eventData {
    if (eventData == nil) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"Extension event error: eventData is nil!"];
        return;
    }

    NSString *action = eventData[ADJAdobeEventDataKeyAction];
    NSDictionary *contextdata = eventData[ADJAdobeEventDataKeyContextData];
    if (contextdata == nil) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"Extension event error: contextdata is nil!"];
        return;
    }

    if (action.length > 0 &&
        [action compare:ADJAdobeAdjustActionSetPushToken options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        [self setPushToken:contextdata];
    } else {
        [self trackEvent:contextdata];
    }
}

- (void)setPushToken:(NSDictionary<NSString *, NSString *> *)contextData {
    NSString *pushToken = contextData[ADJAdobeAdjustPushToken];
    if (pushToken != nil && pushToken.length > 0) {
        [Adjust setPushToken:pushToken];
    } else {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"PushToken is nil or zero-length!"];
    }
}

- (void)trackEvent:(NSDictionary<NSString *, NSString *> *)contextData {
    NSString *adjEventToken = contextData[ADJAdobeAdjustEventToken];
    if (adjEventToken == nil) {
        return;
    }

    ADJEvent *event = [ADJEvent eventWithEventToken:adjEventToken];
    NSString *currency = contextData[ADJAdobeAdjustEventCurrency];
    NSString *revenue = contextData[ADJAdobeAdjustEventRevenue];

    // Revenue data
    if (currency != nil && currency.length > 0 && revenue != nil && revenue.length > 0) {
        NSNumber *numRevenue = [NSNumber numberWithDouble:[revenue doubleValue]];
        if ([numRevenue isEqualToNumber:self.numNan] ||
            [numRevenue isEqualToNumber:self.numPlusInf] ||
            [numRevenue isEqualToNumber:self.numMinusInf]) {
            [ACPCore log:ACPMobileLogLevelError
                     tag:ADJAdobeExtensionLogTag
                 message:@"Revenue number is malformed!"];
            return;
        } else {
            [event setRevenue:[numRevenue doubleValue] currency:currency];
        }
    }

    // Callback / Partner Params
    NSArray *allKeys = contextData.allKeys;
    for (NSString *key in allKeys) {
        if ([key hasPrefix:ADJAdobeAdjustEventCallbackParamPrefix] == YES) {
            NSString *adjKey = [key substringFromIndex:ADJAdobeAdjustEventCallbackParamPrefix.length];
            [event addCallbackParameter:adjKey value:[contextData valueForKey:key]];
        } else if ([key hasPrefix:ADJAdobeAdjustEventPartnerParamPrefix] == YES) {
            NSString *adjKey = [key substringFromIndex:ADJAdobeAdjustEventPartnerParamPrefix.length];
            [event addPartnerParameter:adjKey value:[contextData valueForKey:key]];
        }
    }

    [Adjust trackEvent:event];
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
