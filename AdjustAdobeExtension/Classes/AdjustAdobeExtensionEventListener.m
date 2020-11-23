//
//  AdjustAdobeExtensionEventListener.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 28/09/2020.
//  Copyright (c) 2020 Adjust GmbH. All rights reserved.
//

#import "AdjustAdobeExtensionEventListener.h"
#import "AdjustAdobeExtension.h"

NSString * const ADJAdobeEventTypeGenericTrack = @"com.adobe.eventType.generic.track";
NSString * const ADJAdobeEventSourceRequestContent = @"com.adobe.eventSource.requestContent";

@implementation AdjustAdobeExtensionEventListener

- (void)hear:(nonnull ACPExtensionEvent *)event {
    if (![self.extension isKindOfClass:[AdjustAdobeExtension class]]) {
        return;
    }

    AdjustAdobeExtension *adjExt = (AdjustAdobeExtension *)[self extension];
    [adjExt handleEventData:event.eventData];
}

@end
