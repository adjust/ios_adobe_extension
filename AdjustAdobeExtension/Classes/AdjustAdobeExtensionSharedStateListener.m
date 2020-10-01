//
//  AdjustAdobeExtensionEventListener.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 04/09/2020.
//

#import "AdjustAdobeExtensionSharedStateListener.h"

@implementation AdjustAdobeExtensionSharedStateListener

- (void)hear:(ACPExtensionEvent *)event {
    
    NSLog(@"received shared event: %@", event);
    
}

@end
