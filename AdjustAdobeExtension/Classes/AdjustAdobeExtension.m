//
//  AdjustAdobeExtension.m
//  AdjustAdobeExtension
//
//  Created by Adjust SDK Team on 09/04/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import "AdjustAdobeExtension.h"
@import AEPCore;
@import AEPServices;

#pragma mark Public Constants

// Adjust 'Track Event' action type
NSString * const ADJAdobeAdjustActionTrackEvent = @"adj.trackEvent";
// Adjust 'Set Push Token' action type
NSString * const ADJAdobeAdjustActionSetPushToken = @"adj.setPushToken";

// Adjust 'Track Event' action fields keys
NSString * const ADJAdobeAdjustEventToken = @"adj.eventToken";
NSString * const ADJAdobeAdjustEventCurrency = @"adj.currency";
NSString * const ADJAdobeAdjustEventRevenue = @"adj.revenue";
NSString * const ADJAdobeAdjustEventCallbackParamPrefix = @"adj.event.callback.";
NSString * const ADJAdobeAdjustEventPartnerParamPrefix = @"adj.event.partner.";

// Adjust 'Set Push Token' action field key
NSString * const ADJAdobeAdjustPushToken = @"adj.pushToken";

#pragma mark Internal Constants

NSString * const ADJAdobeExtensionSdkPrefix = @"adobe_ext2.0.0";
NSString * const ADJAdobeExtensionLogTag = @"AdjustAdobeExtension";
NSString * const ADJAdobeExtensionName = @"com.adjust.adobeextension";
NSString * const ADJAdobeEventDataKeyAction = @"action";
NSString * const ADJAdobeEventDataKeyContextData = @"contextdata";

// Adjust Adobe extension listeners
// EVENT LISTENER related Adobe keys
NSString * const ADJAdobeEventTypeGenericTrack = @"com.adobe.eventType.generic.track";
NSString * const ADJAdobeEventSourceRequestContent = @"com.adobe.eventSource.requestContent";

// SHARED STATE LISTENER related Adobe keys
NSString * const ADJAdobeEventTypeHub = @"com.adobe.eventType.hub";
NSString * const ADJAdobeEventSourceSharedState = @"com.adobe.eventSource.sharedState";
NSString * const ADJAdobeModuleConfiguration = @"com.adobe.module.configuration";
NSString * const ADJAdobeSharedStateOwnerKey = @"stateowner";

// Adjust Configuration keys
NSString * const ADJConfigurationAppToken = @"adjustAppToken";
NSString * const ADJConfigurationTrackAttribution = @"adjustTrackAttribution";

// Internal synchronization queue identifier
char * const kQUEUE_ID_SYNC = "com.adjust.AdjustAdobeExtension.sync_queue";

// Adjust Static Adobe Configuration
static AdjustAdobeExtensionConfig *_configInstance = nil;

@interface AdjustAdobeExtension () <AEPExtension>
@property (nonatomic, assign) BOOL sdkInitialized;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *receivedEvents;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic,strong) NSNumber *numNan;
@property (nonatomic,strong) NSNumber *numPlusInf;
@property (nonatomic,strong) NSNumber *numMinusInf;
@property (nonatomic, strong) id<AEPExtensionRuntime> extensionRuntime;
@end

@implementation AdjustAdobeExtension

#pragma mark Public Class methods

+ (void)setConfiguration:(AdjustAdobeExtensionConfig *)config {
    _configInstance = config;
}

+ (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        // Pass deep link to Adjust in order to potentially reattribute user.
        ADJDeeplink *deeplink = [[ADJDeeplink alloc] initWithDeeplink:[userActivity webpageURL]];
        [Adjust processDeeplink:deeplink];
    }
    return YES;
}

+ (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary *)options {
    // Pass deep link to Adjust in order to potentially reattribute user.
    ADJDeeplink *deeplink = [[ADJDeeplink alloc] initWithDeeplink:url];
    [Adjust processDeeplink:deeplink];
    return YES;
}

#pragma mark AEPExtension interface implementation

+ (NSString * _Nonnull)extensionVersion {
    __block NSString *extensionVersion;
    [Adjust sdkVersionWithCompletionHandler:^(NSString * _Nullable sdkVersion) {
        extensionVersion = sdkVersion;
    }];

    return (extensionVersion) ? [NSString stringWithFormat:@"%@@%@",
                           ADJAdobeExtensionSdkPrefix, extensionVersion] : @"error fetching SDK version";

}

- (nonnull NSString *)name {
    return ADJAdobeExtensionName;
}

- (NSString *)friendlyName {
    return ADJAdobeExtensionLogTag;
}

- (NSDictionary<NSString *,NSString *> *)metadata {
    return nil;
}

- (id<AEPExtensionRuntime>)runtime {
    return self.extensionRuntime;
}

- (nullable instancetype)initWithRuntime:(id<AEPExtensionRuntime> _Nonnull)runtime {

    self = [super init];
    if (self == nil) {
        return nil;
    }

    _extensionRuntime = runtime;
    _sdkInitialized = NO;
    _receivedEvents = [NSMutableArray array];
    _syncQueue = dispatch_queue_create(kQUEUE_ID_SYNC, DISPATCH_QUEUE_SERIAL);

    double dblZero = 0.0;
    double dblPlusOne = 1.0;
    double dblMinusOne = -1.0;
    _numPlusInf = [NSNumber numberWithDouble:dblPlusOne/dblZero];
    _numMinusInf = [NSNumber numberWithDouble:dblMinusOne/dblZero];
    _numNan = [NSNumber numberWithDouble:sqrt(dblMinusOne)];

    return self;
}

- (void)onRegistered {

    [self.extensionRuntime registerListenerWithType:ADJAdobeEventTypeHub
                                             source:ADJAdobeEventSourceSharedState
                                           listener:^(AEPEvent * _Nonnull sharedStateEvent) {

        if (sharedStateEvent.data == nil) {
            [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping Shared State handling. Shared State Event Data is nil."];
            return;
        }

        if (![sharedStateEvent.data[ADJAdobeSharedStateOwnerKey] isEqualToString:ADJAdobeModuleConfiguration]) {
            return;
        }

        AEPSharedStateResult *result = [self.extensionRuntime getSharedStateWithExtensionName:ADJAdobeModuleConfiguration
                                                                                        event:sharedStateEvent
                                                                                      barrier:NO];
        if (result.status != AEPSharedStateStatusSet) {
            [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping Shared State handling. Configuration Shared State is still not set."];
            return;
        }

        [self configurationDictionaryDidReceive:result.value];
    }];

    [self.extensionRuntime registerListenerWithType:ADJAdobeEventTypeGenericTrack
                                             source:ADJAdobeEventSourceRequestContent
                                           listener:^(AEPEvent * _Nonnull genericTrack) {
        if (genericTrack.data == nil) {
            [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping generic track event. Event's Data is nil."];
            return;
        }
        
        NSString *action = genericTrack.data[ADJAdobeEventDataKeyAction];
        if (action == nil || action.length == 0) {
            [AEPLog debugWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping generic track event. Event's Adjust Action is nil or empty."];
            return;
        }

        if (![self isAdjustActionSupported:action]) {
            NSString *message = [NSString stringWithFormat:@"Skipping generic track event. [%@] type is not supported by Adjust.",
                                 action];
            [AEPLog debugWithLabel:ADJAdobeExtensionLogTag message:message];

            return;
        }

        NSDictionary *contextDataDict = genericTrack.data[ADJAdobeEventDataKeyContextData];

        if (contextDataDict == nil) {
            [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping generic track event. Event's Adjust Context Data is nil."];
            return;
        }

        if (![contextDataDict isKindOfClass:[NSDictionary class]]) {
            [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping generic track event. Event's Adjust Context Data is not a dictionary."];
            return;
        }

        if (contextDataDict.count == 0) {
            [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping generic track event. Event's Adjust Context Data is empty."];
            return;
        }

        [self trackEventDictionaryDidReceive:genericTrack.data];
    }];
}

- (void)onUnregistered {
}

- (BOOL)readyForEvent:(AEPEvent * _Nonnull)event {
    AEPSharedStateResult *result = [self.extensionRuntime getSharedStateWithExtensionName:ADJAdobeModuleConfiguration
                                                                                    event:event
                                                                                  barrier:NO];
    return (result.status == AEPSharedStateStatusSet);
}

#pragma mark Internal logic

- (void)configurationDictionaryDidReceive:(nullable NSDictionary<NSString *, id> *)configDict {

    if (configDict == nil) {
        [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                       message:@"Skipping Adjust setup. Configuration Shared State Data is nil."];
        return;
    }

    NSString *adjustAppToken = [configDict objectForKey:ADJConfigurationAppToken];
    if (adjustAppToken == nil) {
        [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                       message:@"Skipping Adjust setup. Adoby configuration module error: Adjust App Token is nil."];
        return;
    }

    id adjustTrackAttribution = [configDict objectForKey:ADJConfigurationTrackAttribution];
    if (adjustTrackAttribution == nil) {
        [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                       message:@"Skipping Adjust setup. Adoby configuration module error: Adjust Trak Attribution is nil."];
        return;
    }

    BOOL shouldTrackAttribution = ([adjustTrackAttribution isKindOfClass:[NSNumber class]] &&
                                   [adjustTrackAttribution integerValue] == 1);

    [self setupAdjustSdkWithAppToken:adjustAppToken trackAttribution:shouldTrackAttribution];
}

- (void)setupAdjustSdkWithAppToken:(NSString *)appToken trackAttribution:(BOOL)trackAttribution {

    dispatch_async(self.syncQueue, ^{

        if (!_configInstance) {
            [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping Adjust SDK initialization. Adjust Extension Configuration should be set first!"];
            return;
        }

        if (self.sdkInitialized == YES) {
            [AEPLog traceWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping Adjust SDK initialization. Already Initialized."];
            return;
        }

        self.sdkInitialized = YES;

        _configInstance.shouldTrackAttribution = trackAttribution;
        ADJConfig *adjustConfig = [[ADJConfig alloc] initWithAppToken:appToken
                                                    environment:_configInstance.environment];
        [adjustConfig setSdkPrefix:ADJAdobeExtensionSdkPrefix];
        [adjustConfig setExternalDeviceId:_configInstance.externalDeviceId];
        [adjustConfig setDelegate:self];

        switch ([AEPLog logFilter]) {
            case AEPLogLevelError:
                [adjustConfig setLogLevel:ADJLogLevelError];
                break;
            case AEPLogLevelWarning:
                [adjustConfig setLogLevel:ADJLogLevelWarn];
                break;
            case AEPLogLevelDebug:
                [adjustConfig setLogLevel:ADJLogLevelDebug];
                break;
            case AEPLogLevelTrace:
                [adjustConfig setLogLevel:ADJLogLevelVerbose];
                break;
        }

        [Adjust initSdk:adjustConfig];

        for (NSDictionary *event in self.receivedEvents) {
            [self processEvent:event];
        }
        [self.receivedEvents removeAllObjects];
    });
}

- (void)trackEventDictionaryDidReceive:(nonnull NSDictionary *)eventData {
    dispatch_async(self.syncQueue, ^{
        if (!self.sdkInitialized) {
            [self.receivedEvents addObject:eventData];
        } else {
            [self processEvent:eventData];
        }
    });
}

- (void)processEvent:(nonnull NSDictionary *)eventData {
    NSString *action = eventData[ADJAdobeEventDataKeyAction];
    NSDictionary *contextdata = eventData[ADJAdobeEventDataKeyContextData];

    if ([action compare:ADJAdobeAdjustActionSetPushToken
                options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        [self setPushToken:contextdata];
    } else if ([action compare:ADJAdobeAdjustActionTrackEvent
                       options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        [self trackEvent:contextdata];
    } else {
        NSString *message = [NSString stringWithFormat:@"Missing implementation of [%@] handling.",
                             action];
        [AEPLog errorWithLabel:ADJAdobeExtensionLogTag message:message];
    }
}

- (void)setPushToken:(NSDictionary<NSString *, NSString *> *)contextData {
    NSString *pushToken = contextData[ADJAdobeAdjustPushToken];
    if (pushToken == nil || pushToken.length == 0) {
        [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                       message:@"Skipping Set Push Token action. Push Token is nil or empty."];
        return;
    }
    [Adjust setPushTokenAsString:pushToken];
}

- (void)trackEvent:(NSDictionary<NSString *, NSString *> *)contextData {
    NSString *adjEventToken = contextData[ADJAdobeAdjustEventToken];
    if (adjEventToken == nil ||
        ![adjEventToken isKindOfClass:[NSString class]] ||
        adjEventToken.length == 0) {
        [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                       message:@"Skipping Track Event action. Event Token is nil or empty."];
        return;
    }

    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:adjEventToken];
    NSString *currency = contextData[ADJAdobeAdjustEventCurrency];
    NSString *revenue = contextData[ADJAdobeAdjustEventRevenue];

    // Revenue data
    if (currency != nil && [currency isMemberOfClass:[NSString class]] && currency.length > 0 &&
        revenue != nil && [revenue isMemberOfClass:[NSString class]] && revenue.length > 0) {
        NSNumber *numRevenue = [NSNumber numberWithDouble:[revenue doubleValue]];
        if ([numRevenue isEqualToNumber:self.numNan] ||
            [numRevenue isEqualToNumber:self.numPlusInf] ||
            [numRevenue isEqualToNumber:self.numMinusInf]) {
            [AEPLog errorWithLabel:ADJAdobeExtensionLogTag
                           message:@"Skipping Track Event action. Revenue number is malformed."];
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

- (BOOL)isAdjustActionSupported:(nonnull NSString *)action {
    if ([action compare:ADJAdobeAdjustActionSetPushToken
                options:NSCaseInsensitiveSearch] == NSOrderedSame ||
        [action compare:ADJAdobeAdjustActionTrackEvent
                options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return YES;
    }
    return NO;
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

        [AEPMobileCore trackAction:@"Adjust Campaign Data Received"
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
