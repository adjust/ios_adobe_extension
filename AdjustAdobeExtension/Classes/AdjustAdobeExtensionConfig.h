//
//  AdjustAdobeExtensionConfig.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 01/10/2020.
//

#import <Foundation/Foundation.h>
#import <Adjust/Adjust.h>

typedef void (^CallbackAttributionChangedBlock)(ADJAttribution * _Nullable attribution);
typedef BOOL (^CallbackDeeplinkResponseBlock)(NSURL * _Nullable deeplink);

NS_ASSUME_NONNULL_BEGIN

@interface AdjustAdobeExtensionConfig : NSObject

@property (nonatomic, copy, readonly, nullable) CallbackAttributionChangedBlock attributionChangedBlock;
@property (nonatomic, copy, readonly, nullable) CallbackDeeplinkResponseBlock deeplinkResponseBlock;
@property (nonatomic, copy, readonly, nonnull) NSString *environment;
@property (nonatomic, assign) BOOL shouldTrackAttribution;

+ (nullable AdjustAdobeExtensionConfig *)configWithEnvironment:(nonnull NSString *)environment;

- (void)callbackAttributionChanged:(CallbackAttributionChangedBlock)attributionChangedBlock;
- (void)callbackDeeplinkResponse:(CallbackDeeplinkResponseBlock)deeplinkResponseBlock;

@end

NS_ASSUME_NONNULL_END
