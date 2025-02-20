//
//  AdjustAdobeExtensionConfig.h
//  AdjustAdobeExtension
//
//  Created by Adjust SDK Team on 01/10/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<AdjustSdk/AdjustSdk.h>)
#import <AdjustSdk/AdjustSdk.h>
#else
#import <AdjustSdk.h>
#endif

typedef void (^CallbackAttributionChangedBlock)(ADJAttribution * _Nullable attribution);
typedef BOOL (^CallbackDeferredDeeplinkReceivedBlock)(NSURL * _Nullable deeplink);

NS_ASSUME_NONNULL_BEGIN

@interface AdjustAdobeExtensionConfig : NSObject

@property (nonatomic, strong, readonly, nullable) CallbackAttributionChangedBlock attributionChangedBlock;
@property (nonatomic, strong, readonly, nullable) CallbackDeferredDeeplinkReceivedBlock deferredDeeplinkReceivedBlock;
@property (nonatomic, copy, readonly, nonnull) NSString *environment;
@property (nonatomic, copy, readonly, nonnull) NSString *defaultTracker;
@property (nonatomic, copy, readonly, nonnull) NSString *externalDeviceId;
@property (nonatomic, assign) BOOL shouldTrackAttribution;

+ (nullable AdjustAdobeExtensionConfig *)configWithEnvironment:(nonnull NSString *)environment;

- (void)setAttributionChangedBlock:(CallbackAttributionChangedBlock _Nullable)attributionChangedBlock;
- (void)setDeferredDeeplinkReceivedBlock:(CallbackDeferredDeeplinkReceivedBlock _Nullable)deferredDeeplinkReceivedBlock;
- (void)setDefaultTracker:(NSString *)defaultTracker;
- (void)setExternalDeviceId:(NSString *)externalDeviceId;

@end

NS_ASSUME_NONNULL_END

