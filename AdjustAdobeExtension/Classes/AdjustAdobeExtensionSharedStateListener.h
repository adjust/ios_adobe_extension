//
//  AdjustAdobeExtensionSharedStateListener.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 04/09/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import <ACPCore/ACPCore.h>
#import <ACPCore/ACPExtensionListener.h>
#import <ACPCore/ACPExtensionEvent.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ADJAdobeEventTypeHub;
extern NSString * const ADJAdobeEventSourceSharedState;

@interface AdjustAdobeExtensionSharedStateListener : ACPExtensionListener

- (void)hear:(ACPExtensionEvent *)event;

@end

NS_ASSUME_NONNULL_END
