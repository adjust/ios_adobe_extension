//
//  AdjustAdobeExtensionSharedStateListener.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 04/09/2020.
//  Copyright (c) 2020 Adjust GmbH. All rights reserved.
//

#import <ACPCore/ACPCore.h>
#import <ACPCore/ACPExtensionListener.h>
#import <ACPCore/ACPExtensionEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdjustAdobeExtensionSharedStateListener : ACPExtensionListener

- (void)hear:(ACPExtensionEvent *)event;

@end

NS_ASSUME_NONNULL_END
