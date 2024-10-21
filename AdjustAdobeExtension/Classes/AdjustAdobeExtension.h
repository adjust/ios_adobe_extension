//
//  AdjustAdobeExtension.h
//  AdjustAdobeExtension
//
//  Created by Adjust SDK Team on 09/04/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Adjust Native SDK
#if defined(__has_include) && __has_include(<AdjustSdk/AdjustSdk.h>)
#import <AdjustSdk/AdjustSdk.h>
#else
#import "AdjustSdk.h"
#endif

#import "AdjustAdobeExtensionConfig.h"

NS_ASSUME_NONNULL_BEGIN
// Adjust 'Track Event' action type
extern NSString * const ADJAdobeAdjustActionTrackEvent;
// Adjust 'Set Push Token' action type
extern NSString * const ADJAdobeAdjustActionSetPushToken;

// Adjust 'Track Event' action fields keys
extern NSString * const ADJAdobeAdjustEventToken;
extern NSString * const ADJAdobeAdjustEventCurrency;
extern NSString * const ADJAdobeAdjustEventRevenue;
extern NSString * const ADJAdobeAdjustEventCallbackParamPrefix;
extern NSString * const ADJAdobeAdjustEventPartnerParamPrefix;

// Adjust 'Set Push Token' action field key
extern NSString * const ADJAdobeAdjustPushToken;

NS_ASSUME_NONNULL_END

@interface AdjustAdobeExtension : NSObject <AdjustDelegate>
+ (void)setConfiguration:(AdjustAdobeExtensionConfig *_Nonnull)config;
+ (BOOL)application:(UIApplication *_Nonnull)application continueUserActivity:(NSUserActivity *_Nonnull)userActivity;
+ (BOOL)application:(UIApplication *_Nonnull)application openURL:(NSURL *_Nonnull)url options:(NSDictionary *_Nonnull)options;

@end

