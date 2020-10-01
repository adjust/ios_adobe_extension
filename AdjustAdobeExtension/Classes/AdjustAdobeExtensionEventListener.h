//
//  AdjustAdobeExtensionEventListener.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 28/09/2020.
//

#import <Foundation/Foundation.h>
#import <ACPCore/ACPExtensionEvent.h>
#import <ACPCore/ACPExtensionListener.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdjustAdobeExtensionEventListener : ACPExtensionListener

- (void)hear:(nonnull ACPExtensionEvent*)event;

@end

NS_ASSUME_NONNULL_END
