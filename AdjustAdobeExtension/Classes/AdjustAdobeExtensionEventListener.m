//
//  AdjustAdobeExtensionEventListener.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 28/09/2020.
//

#import "AdjustAdobeExtensionEventListener.h"
#import "AdjustAdobeExtension.h"

NSString *const ADJAdobeEventTypeGenericTrack = @"com.adobe.eventType.generic.track";
NSString *const ADJAdobeEventSourceRequestContent = @"com.adobe.eventSource.requestContent";

@implementation AdjustAdobeExtensionEventListener

- (void)hear:(nonnull ACPExtensionEvent*)event {
    AdjustAdobeExtension *adjExt = nil;
    if ([self.extension isKindOfClass:[AdjustAdobeExtension class]]) {
        adjExt = (AdjustAdobeExtension*) [self extension];
    }

    [adjExt handleEventData:event.eventData];
}

@end
