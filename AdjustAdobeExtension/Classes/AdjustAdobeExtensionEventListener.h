//
//  AdjustAdobeExtensionEventListener.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 28/09/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ACPCore/ACPExtensionEvent.h>
#import <ACPCore/ACPExtensionListener.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const ADJAdobeEventTypeGenericTrack;
extern NSString * const ADJAdobeEventSourceRequestContent;

@interface AdjustAdobeExtensionEventListener : ACPExtensionListener

- (void)hear:(nonnull ACPExtensionEvent *)event;

@end

NS_ASSUME_NONNULL_END
