//
//  AdjustAdobeExtension.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 04/09/2020.
//

#import "AdjustAdobeExtension.h"
#import "AdjustAdobeExtensionSharedStateListener.h"
#import "AdjustAdobeExtensionEventListener.h"

NSString *const ADJAdobeExtensionLogTag = @"AdjustAdobeExtension";

NSString *const ADJAdobeAdjustEventToken = @"adj.eventToken";
NSString *const ADJAdobeAdjustEventCurrency = @"currency";
NSString *const ADJAdobeAdjustEventRevenue = @"revenue";

static AdjustAdobeExtensionConfig *_configInstance = nil;

@interface AdjustAdobeExtension()

@property (nonatomic, assign) BOOL sdkInitialized;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *receivedEvents;

@end

@implementation AdjustAdobeExtension

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.sdkInitialized = NO;
        self.receivedEvents = [NSMutableArray array];
        
        NSError* error = nil;
        
        // Shared State listener
        if ([self.api registerListener:[AdjustAdobeExtensionSharedStateListener class]
                             eventType:@"com.adobe.eventType.hub"
                           eventSource:@"com.adobe.eventSource.sharedState"
                                 error:&error]) {
            [ACPCore log:ACPMobileLogLevelDebug tag:ADJAdobeExtensionLogTag
                 message:@"successfully registered for Event Hub Shared State events"];
        } else if (error) {
            [ACPCore log:ACPMobileLogLevelError tag:ADJAdobeExtensionLogTag
                 message:[NSString stringWithFormat:@"An error occured while registering AdjustAdobeExtensionSharedStateListener, error code: %ld",
                            [error code]]];
        }
        
        if ([self.api registerListener:[AdjustAdobeExtensionEventListener class]
                             eventType:@"com.adobe.eventType.generic.track"
                           eventSource:@"com.adobe.eventSource.requestContent"
                                 error:&error]) {
            [ACPCore log:ACPMobileLogLevelDebug tag:ADJAdobeExtensionLogTag
                 message:@"Successfully registered for Extension Request Content events"];
        } else if (error) {
            [ACPCore log:ACPMobileLogLevelError tag:ADJAdobeExtensionLogTag
                 message:[NSString stringWithFormat:@"There was an error registering ExtensionListener for Extension Request Content events: %@",
                          error.localizedDescription ?: @"unknown"]];
        }
        
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

- (void)setupAdjustWithAppToken:(NSString *)appToken trackAttribution:(BOOL)trackAttribution {
    
    if (!_configInstance) {
        [ACPCore log:ACPMobileLogLevelError tag:ADJAdobeExtensionLogTag message:@"Extension should be registered first"];
        return;
    }
    
    if (!self.sdkInitialized) {
        _configInstance.shouldTrackAttribution = trackAttribution;
        
        ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken
                                                    environment:_configInstance.environment];
        [adjustConfig setDelegate:self];
        
        [Adjust appDidLaunch:adjustConfig];
        
        self.sdkInitialized = YES;
        [self dumpReceivedEvents];
    }
}

- (void)dumpReceivedEvents {
    if (self.receivedEvents.count > 0) {
        // dump events received before initialization
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            for (NSDictionary *event in self.receivedEvents) {
                [self handleEventData:event];
            }
            [self.receivedEvents removeAllObjects];
        });
    }
}

+ (void)registerExtensionWithConfig:(AdjustAdobeExtensionConfig *)config {
    NSError *error = nil;
    if ([ACPCore registerExtension:[AdjustAdobeExtension class] error:&error]) {
        [ACPCore log:ACPMobileLogLevelDebug tag:ADJAdobeExtensionLogTag
             message:@"Successfully registered AdjustExtension"];
        _configInstance = config;
    } else {
        [ACPCore log:ACPMobileLogLevelError tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:@"Error registering AdjustExtension: %@ %d",
                      [error domain], (int)[error code]]];
    }
}

- (nullable NSString*) name {
    return @"com.adjust.extension.adobe";
}

- (nullable NSString*) version {
    return [NSString stringWithFormat:@"Adjust SDK version %ld", (long)[Adjust version]];
}

#pragma mark - Adjust delegate

- (void)adjustAttributionChanged:(nullable ADJAttribution *)attribution {
    if (_configInstance.shouldTrackAttribution) {
        NSDictionary *attrDict = [attribution dictionary];
        NSMutableDictionary *attrDictPrefix = [NSMutableDictionary dictionary];
        
        for (id key in attrDict) {
            NSString *keyPrefix = [NSString stringWithFormat:@"%@%@", @"adjust.", key];
            attrDictPrefix[keyPrefix] = attrDict[key];
        }
        
        [ACPCore trackAction:@"Adjust Attribution Data"
                        data:attrDictPrefix];
    }
    
    if (_configInstance.attributionChangedBlock) {
        _configInstance.attributionChangedBlock(attribution);
    }
}

- (void)adjustEventTrackingSucceeded:(nullable ADJEventSuccess *)eventSuccessResponseData {
    if (_configInstance.eventTrackingSucceededBlock) {
        _configInstance.eventTrackingSucceededBlock(eventSuccessResponseData);
    }
}

- (void)adjustEventTrackingFailed:(nullable ADJEventFailure *)eventFailureResponseData {
    if (_configInstance.eventTrackingFailedBlock) {
        _configInstance.eventTrackingFailedBlock(eventFailureResponseData);
    }
}

- (void)adjustSessionTrackingSucceeded:(nullable ADJSessionSuccess *)sessionSuccessResponseData {
    if (_configInstance.sessionTrackingSucceededBlock) {
        _configInstance.sessionTrackingSucceededBlock(sessionSuccessResponseData);
    }
}

- (void)adjustSessionTrackingFailed:(nullable ADJSessionFailure *)sessionFailureResponseData {
    if (_configInstance.sessionTrackingFailedBlock) {
        _configInstance.sessionTrackingFailedBlock(sessionFailureResponseData);
    }
}

- (BOOL)adjustDeeplinkResponse:(nullable NSURL *)deeplink {
    if (_configInstance.deeplinkResponseBlock) {
        return _configInstance.deeplinkResponseBlock(deeplink);
    }
    
    return NO;
    
}

@end
