//
//  AdjustAdobeExtensionConfig.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 01/10/2020.
//

#import <Foundation/Foundation.h>
#import <Adjust/Adjust.h>

typedef void (^CallbackAttributionChangedBlock)(ADJAttribution * _Nullable attribution);
typedef void (^CallbackEventTrackingSucceededBlock)(ADJEventSuccess * _Nullable eventSuccessResponseData);
typedef void (^CallbackEventTrackingFailedBlock)(ADJEventFailure * _Nullable eventFailureResponseData);
typedef void (^CallbackSessionTrackingSucceededBlock)(ADJSessionSuccess * _Nullable sessionSuccessResponseData);
typedef void (^CallbackSessionTrackingFailedBlock)(ADJSessionFailure * _Nullable sessionFailureResponseData);
typedef void (^CallbackDeeplinkResponseBlock)(NSURL * _Nullable deeplink);

NS_ASSUME_NONNULL_BEGIN

@interface AdjustAdobeExtensionConfig : NSObject

@property (nonatomic, copy, readonly, nullable) CallbackAttributionChangedBlock attributionChangedBlock;
@property (nonatomic, copy, readonly, nullable) CallbackEventTrackingSucceededBlock eventTrackingSucceededBlock;
@property (nonatomic, copy, readonly, nullable) CallbackEventTrackingFailedBlock eventTrackingFailedBlock;
@property (nonatomic, copy, readonly, nullable) CallbackSessionTrackingSucceededBlock sessionTrackingSucceededBlock;
@property (nonatomic, copy, readonly, nullable) CallbackSessionTrackingFailedBlock sessionTrackingFailedBlock;
@property (nonatomic, copy, readonly, nullable) CallbackDeeplinkResponseBlock deeplinkResponseBlock;
@property (nonatomic, copy, readonly, nonnull) NSString *environment;
@property (nonatomic, assign) BOOL shouldTrackAttribution;

+ (nullable AdjustAdobeExtensionConfig *)configWithEnvironment:(nonnull NSString *)environment;

- (void)callbackAttributionChanged:(CallbackAttributionChangedBlock)attributionChangedBlock;
- (void)callbackEventTrackingSucceeded:(CallbackEventTrackingSucceededBlock)eventTrackingSucceededBlock;
- (void)callbackEventTrackingFailed:(CallbackEventTrackingFailedBlock)eventTrackingFailedBlock;
- (void)callbackSessionTrackingSucceeded:(CallbackSessionTrackingSucceededBlock)sessionTrackingSucceededBlock;
- (void)callbackSessionTrackingFailed:(CallbackSessionTrackingFailedBlock)sessionTrackingFailedBlock;
- (void)callbackDeeplinkResponse:(CallbackDeeplinkResponseBlock)deeplinkResponseBlock;

@end

NS_ASSUME_NONNULL_END
