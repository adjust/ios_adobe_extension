//
//  AdjustAdobeExtensionEventListener.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho on 04/09/2020.
//

#import "AdjustAdobeExtensionSharedStateListener.h"
#import "AdjustAdobeExtension.h"
#import <ACPCore/ACPExtension.h>

NSString *const ADJAdobeModuleConfiguration = @"com.adobe.module.configuration";

NSString *const ADJConfigurationAppToken = @"adjustAppToken";
NSString *const ADJConfigurationTrackAttribution = @"adjustTrackAttribution";

@implementation AdjustAdobeExtensionSharedStateListener

- (void)hear:(ACPExtensionEvent *)event {
    
    NSDictionary *eventData = [event eventData];

    if (!eventData) {
        return;
    }
    
    if ([eventData[@"stateowner"] isEqualToString:ADJAdobeModuleConfiguration]) {
        NSError *error = nil;
        NSDictionary *configSharedState = [self.extension.api getSharedEventState:ADJAdobeModuleConfiguration event:event error:&error];
        if (error) {
            [ACPCore log:ACPMobileLogLevelError tag:ADJAdobeExtensionLogTag
                 message:[NSString stringWithFormat:@"Error on getSharedEventState %@:%ld.", [error domain], [error code]]];
            return;
        }
        
        if ([configSharedState objectForKey:ADJConfigurationAppToken] && [configSharedState objectForKey:ADJConfigurationTrackAttribution]) {
            
            AdjustAdobeExtension *adjExt = nil;
            if ([self.extension isKindOfClass:[AdjustAdobeExtension class]]) {
                adjExt = (AdjustAdobeExtension*) [self extension];
            }
            
            NSString *adjustAppToken = [configSharedState objectForKey:ADJConfigurationAppToken];
            id adjustTrackAttribution = [configSharedState objectForKey:ADJConfigurationTrackAttribution];
            BOOL shouldTrackAttribution = [adjustTrackAttribution isKindOfClass:[NSNumber class]] && [adjustTrackAttribution integerValue] == 1;
            
            [adjExt setupAdjustWithAppToken:adjustAppToken trackAttribution:shouldTrackAttribution];
            
        }
    }
    
}

@end
