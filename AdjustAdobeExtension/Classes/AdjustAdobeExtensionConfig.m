//
//  AdjustAdobeExtensionConfig.m
//  AdjustAdobeExtension
//
//  Created by Adjust SDK Team on 01/10/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import "AdjustAdobeExtensionConfig.h"

@implementation AdjustAdobeExtensionConfig

- (nullable id)initWithEnvironment:(NSString *)environment {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    _environment = environment;
    return self;
}

+ (nullable AdjustAdobeExtensionConfig *)configWithEnvironment:(nonnull NSString *)environment {
    return [[AdjustAdobeExtensionConfig alloc] initWithEnvironment:environment];
}

- (void)setAttributionChangedBlock:(CallbackAttributionChangedBlock _Nullable)attributionChangedBlock{
    _attributionChangedBlock = attributionChangedBlock;
}

- (void)setDeeplinkResponseBlock:(CallbackDeeplinkResponseBlock _Nullable)deeplinkResponseBlock {
    _deeplinkResponseBlock = deeplinkResponseBlock;
}

@end
