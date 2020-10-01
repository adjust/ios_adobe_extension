//
//  AdjustAdobeExtension.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 04/09/2020.
//

#import <Foundation/Foundation.h>
#import <ACPCore/ACPCore.h>
#import <ACPCore/ACPExtension.h>
#import <Adjust/Adjust.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ADJAdobeAdjustEventToken;
extern NSString * const ADJAdobeAdjustEventCurrency;
extern NSString * const ADJAdobeAdjustEventRevenue;

@interface AdjustAdobeExtension : ACPExtension

+ (void)registerExtension;

- (void)handleEventData:(nullable NSDictionary *)eventData;

/// Adobe methods
- (nullable NSString*) name;
- (nullable NSString*) version;

@end

NS_ASSUME_NONNULL_END
