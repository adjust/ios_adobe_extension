//
//  AdjustAdobeExtension.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 09/04/2020.
//  Copyright (c) 2020 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ACPCore/ACPCore.h>
#import <ACPCore/ACPExtension.h>
#import <Adjust/Adjust.h>
#import "AdjustAdobeExtensionConfig.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ADJAdobeAdjustEventToken;
extern NSString * const ADJAdobeAdjustEventCurrency;
extern NSString * const ADJAdobeAdjustEventRevenue;
extern NSString * const ADJAdobeExtensionLogTag;
extern NSString * const ADJAdobeExtensionSdkPrefix;

@interface AdjustAdobeExtension : ACPExtension <AdjustDelegate>

+ (void)registerExtensionWithConfig:(AdjustAdobeExtensionConfig *)config;

- (void)handleEventData:(nullable NSDictionary *)eventData;
- (void)setupAdjustWithAppToken:(NSString *)appToken trackAttribution:(BOOL)trackAttribution;

/// Adobe methods
- (nullable NSString *)name;
- (nullable NSString *)version;

@end

NS_ASSUME_NONNULL_END
