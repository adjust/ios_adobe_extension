//
//  AdjustAdobeExtensionSharedStateListener.m
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 04/09/2020.
//  Copyright (c) 2020-Present Adjust GmbH. All rights reserved.
//

#import "AdjustAdobeExtensionSharedStateListener.h"
#import "AdjustAdobeExtension.h"
#import <ACPCore/ACPExtension.h>

NSString * const ADJAdobeModuleConfiguration = @"com.adobe.module.configuration";
NSString * const ADJAdobeEventTypeHub = @"com.adobe.eventType.hub";
NSString * const ADJAdobeEventSourceSharedState = @"com.adobe.eventSource.sharedState";

NSString * const ADJConfigurationAppToken = @"adjustAppToken";
NSString * const ADJConfigurationTrackAttribution = @"adjustTrackAttribution";

@implementation AdjustAdobeExtensionSharedStateListener

- (void)hear:(ACPExtensionEvent *)event {
    NSDictionary *eventData = [event eventData];

    if (!eventData) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"Extension eventData is nil!"];
        return;
    }
    if (![eventData[@"stateowner"] isEqualToString:ADJAdobeModuleConfiguration]) {
        return;
    }

    NSError *error = nil;
    NSDictionary *configSharedState = [self.extension.api getSharedEventState:ADJAdobeModuleConfiguration
                                                                        event:event
                                                                        error:&error];
    if (configSharedState == nil || error) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:[NSString stringWithFormat:
                      @"An error occured while calling getSharedEventState: %@",
                      (error) ? [NSString stringWithFormat:@"Code: %ld, Domain: %@, Description: %@.", (long)error.code, error.domain, error.localizedDescription ] :
                      @"Unknown error."]];
         return;
    }

    NSString *adjustAppToken = [configSharedState objectForKey:ADJConfigurationAppToken];
    if (adjustAppToken == nil) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"Extension module configuration error: Adjust App Token is nil!"];
        return;
    }

    id adjustTrackAttribution = [configSharedState objectForKey:ADJConfigurationTrackAttribution];
    if (adjustTrackAttribution == nil) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"Extension module configuration error: Adjust Trak Attribution is nil!"];
        return;
    }

    if (![self.extension isKindOfClass:[AdjustAdobeExtension class]]) {
        [ACPCore log:ACPMobileLogLevelError
                 tag:ADJAdobeExtensionLogTag
             message:@"Extension type is not AdjustAdobeExtension!"];
        return;
    }

    AdjustAdobeExtension *adjExt = (AdjustAdobeExtension *)[self extension];
    BOOL shouldTrackAttribution =
        [adjustTrackAttribution isKindOfClass:[NSNumber class]] && [adjustTrackAttribution integerValue] == 1;

    [adjExt setupAdjustWithAppToken:adjustAppToken trackAttribution:shouldTrackAttribution];
}

@end
