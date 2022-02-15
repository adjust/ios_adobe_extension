//
//  AdjustAdobeExtensionConfig.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 01/10/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import "AdjustAdobeExtensionConfig.h"

@interface AdjustAdobeExtensionConfig()

@end

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

- (void)callbackAttributionChanged:(CallbackAttributionChangedBlock)attributionChangedBlock {
    _attributionChangedBlock = attributionChangedBlock;
}

- (void)callbackDeeplinkResponse:(CallbackDeeplinkResponseBlock)deeplinkResponseBlock {
    _deeplinkResponseBlock = deeplinkResponseBlock;
}

@end
