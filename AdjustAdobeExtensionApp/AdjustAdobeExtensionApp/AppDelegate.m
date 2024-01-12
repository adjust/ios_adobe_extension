//
//  AppDelegate.m
//  AdjustAdobeExtensionApp
//
//  Created by Adjust SDK Team on 21.11.23.
//

#import "AppDelegate.h"
@import AEPCore;
@import AEPServices;
#import <AdjustAdobeExtension/AdjustAdobeExtension.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [AEPMobileCore setLogLevel: AEPLogLevelTrace];
    const UIApplicationState appState = application.applicationState;

    // Adjust Adobe Extension configuration
    AdjustAdobeExtensionConfig *adjustConfig = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
    [adjustConfig setAttributionChangedBlock:^(ADJAttribution * _Nullable attribution) {
        NSLog(@"Adjust Attribution Callback received:[%@]", attribution.description);
    }];
    [adjustConfig setDeeplinkResponseBlock:^BOOL(NSURL * _Nullable deeplink) {
        NSLog(@"Adjust Deeplink response received:[%@]", deeplink.absoluteString);
        return YES;
    }];
    [AdjustAdobeExtension setConfiguration:adjustConfig];

    // Adjust Adobe Extension registration
    [AEPMobileCore registerExtensions:@[AdjustAdobeExtension.class]
                           completion:^{
        //Adobe Launch property: "iOS Test"
        [AEPMobileCore configureWithAppId: @"89645c501ce0/540de252943f/launch-f8d889dd15b6-development"];

        if (appState != UIApplicationStateBackground) {
            // only start lifecycle if the application is not in the background
            [AEPMobileCore lifecycleStart:nil];
        }
    }];

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [AdjustAdobeExtension application:app openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [AdjustAdobeExtension application:application
                        continueUserActivity:userActivity];
}


#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
