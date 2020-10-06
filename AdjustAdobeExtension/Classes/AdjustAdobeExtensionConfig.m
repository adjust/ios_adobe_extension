//
//  AdjustAdobeExtensionConfig.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 01/10/2020.
//

#import "AdjustAdobeExtensionConfig.h"

@interface AdjustAdobeExtensionConfig()

@end

@implementation AdjustAdobeExtensionConfig

- (nullable id)initWithEnvironment:(NSString *)environment {
    self = [super init];
    if (self == nil) return nil;
    
    _environment = environment;
    
    return self;
}

+ (nullable AdjustAdobeExtensionConfig *)configWithEnvironment:(nonnull NSString *)environment {
    return [[AdjustAdobeExtensionConfig alloc] initWithEnvironment:environment];
}

- (void)callbackAttributionChanged:(CallbackAttributionChangedBlock)attributionChangedBlock {
    _attributionChangedBlock = attributionChangedBlock;
}
- (void)callbackEventTrackingSucceeded:(CallbackEventTrackingSucceededBlock)eventTrackingSucceededBlock {
    _eventTrackingSucceededBlock = eventTrackingSucceededBlock;
}
- (void)callbackEventTrackingFailed:(CallbackEventTrackingFailedBlock)eventTrackingFailedBlock {
    _eventTrackingFailedBlock = eventTrackingFailedBlock;
}
- (void)callbackSessionTrackingSucceeded:(CallbackSessionTrackingSucceededBlock)sessionTrackingSucceededBlock {
    _sessionTrackingSucceededBlock = sessionTrackingSucceededBlock;
}
- (void)callbackSessionTrackingFailed:(CallbackSessionTrackingFailedBlock)sessionTrackingFailedBlock {
    _sessionTrackingFailedBlock = sessionTrackingFailedBlock;
}
- (void)callbackDeeplinkResponse:(CallbackDeeplinkResponseBlock)deeplinkResponseBlock {
    _deeplinkResponseBlock = deeplinkResponseBlock;
}

@end
