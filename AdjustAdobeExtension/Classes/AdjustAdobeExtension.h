//
//  AdjustAdobeExtension.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 09/04/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ACPCore/ACPCore.h>
#import <ACPCore/ACPExtension.h>
#if defined(__has_include) && __has_include(<Adjust/Adjust.h>)
#import <Adjust/Adjust.h>
#else
#import <Adjust.h>
#endif
#import "AdjustAdobeExtensionConfig.h"
#import "AdjustAdobeExtensionEventListener.h"
#import "AdjustAdobeExtensionSharedStateListener.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ADJAdobeExtensionLogTag;
extern NSString * const ADJAdobeExtensionSdkPrefix;

// Action types
extern NSString * const ADJAdobeAdjustActionTrackEvent;
extern NSString * const ADJAdobeAdjustActionSetPushToken;

// Adjust Event
extern NSString * const ADJAdobeAdjustEventToken;
extern NSString * const ADJAdobeAdjustEventCurrency;
extern NSString * const ADJAdobeAdjustEventRevenue;
extern NSString * const ADJAdobeAdjustEventCallbackParamPrefix;
extern NSString * const ADJAdobeAdjustEventPartnerParamPrefix;

// Push token
extern NSString * const ADJAdobeAdjustPushToken;

@interface AdjustAdobeExtension : ACPExtension <AdjustDelegate>

+ (void)registerExtensionWithConfig:(AdjustAdobeExtensionConfig *)config;

- (void)handleEventData:(nullable NSDictionary *)eventData;
- (void)setupAdjustWithAppToken:(NSString *)appToken trackAttribution:(BOOL)trackAttribution;

/// Adobe methods
- (nullable NSString *)name;
- (nullable NSString *)version;

@end

NS_ASSUME_NONNULL_END
