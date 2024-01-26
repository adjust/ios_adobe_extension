# Migrate Adjust iOS Extension for Adobe Experience Platform SDK from v1.1.1 to v2.0.0

## Adjust iOS Extension for Adobe Experience Platform SDK documentation

Please refer to the [this document](../README.md) as a general integration information source.

## Update Adjust Adobe extension dependency

### Cocoapods
Run this command at the level of your `Podfile`

```
> pod update
```

### Swift Package Manager

Go to the Xcode->[File]->[Packages]->[Update to Latest Package Versions]

## Add iOS Frameworks (if they are missing)

Adjust SDK is able to get additional information in case you link additional iOS frameworks to your app. Please, add following frameworks in case you want to enable Adjust SDK features based on their presence in your app and mark them as optional:

- `AdSupport.framework` - This framework is needed so that SDK can access to IDFA value and LAT information (prior to iOS 14) .
- `AppTrackingTransparency.framework` - This framework is needed in iOS 14 and later for SDK to be able to wrap user's tracking consent dialog and access to value of the user's consent to be tracked or not.
- `AdServices.framework` - For devices running iOS 14.3 or higher, this framework allows the SDK to automatically handle attribution for ASA campaigns. It is required when leveraging the Apple Ads Attribution API.
- `StoreKit.framework` - This framework is needed for access to `SKAdNetwork` framework and for Adjust SDK to handle communication with it automatically in iOS 14 or later.

You can remove `iAd.framework` if you haven't done this already due to its [phased out state](https://developer.apple.com/documentation/iad?language=objc). 

In the `Frameworks, Libraries, and Embedded Content` section of your App target's `General` tab, you can remove the following frameworks and libraries (in case your App is not using any of them) required for the previous (`ACPCore`) Adobe integration: `UIKit`, `SystemConfiguration`, `WebKit`, `UserNotifications`, `libsqlite3.0`, `libc++`, `libz`.

## Adjust Adobe Extension initialization

Please replace this (old) initialization code:

```objc
// Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ACPCore setLogLevel:ACPMobileLogLevelVerbose];
    [ACPCore configureWithAppId:@"{your_adobe_app_id}"];
    
    AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:{environment}];
    [AdjustAdobeExtension registerExtensionWithConfig:config];

    [ACPCore start:^{
        [ACPCore lifecycleStart:nil];
    }];
    return YES;
}
```

```swift
// Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ACPCore.setLogLevel(ACPMobileLogLevel.verbose)
    ACPCore.configure(withAppId: "{your_adobe_app_id}")

    if let config = AdjustAdobeExtensionConfig.init(environment: {environment}) {
        AdjustAdobeExtension.register(with: config)
    }

    ACPCore.start {
        ACPCore.lifecycleStart(nil)
    }
    return true
}
```

by the following (new) initialization code:

```objc
// Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AEPMobileCore setLogLevel: AEPLogLevelTrace];
    const UIApplicationState appState = application.applicationState;

    // Adjust Adobe Extension configuration
    AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:{environment}];
    [AdjustAdobeExtension setConfiguration:config];

    // Adjust Adobe Extension registration
    [AEPMobileCore registerExtensions:@[AdjustAdobeExtension.class]
                           completion:^{
        [AEPMobileCore configureWithAppId: @"{your_adobe_app_id}"];

        if (appState != UIApplicationStateBackground) {
            // only start lifecycle if the application is not in the background
            [AEPMobileCore lifecycleStart:nil];
        }
    }];
    
    return YES;
}
```

```swift
// Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    MobileCore.setLogLevel(LogLevel.trace)
    let appState = application.applicationState

    // Adjust Adobe Extension configuration
    if let config = AdjustAdobeExtensionConfig(environment: ADJEnvironmentSandbox) {
        AdjustAdobeExtension.setConfiguration(config)
    }

    // Adjust Adobe Extension registration
    MobileCore.registerExtensions([AdjustAdobeExtension.self]) {
        MobileCore.configureWith(appId: "{your_adobe_app_id}")
        if appState != .background {
            // Only start lifecycle if the application is not in the background
            MobileCore.lifecycleStart(additionalContextData: nil)
        }
    }
    return true
}
```

- Replace `{your_adobe_app_id}` with your `Unique identifier assigned to the app instance by Adobe Launch Portal`.
- Set the `{environment}` to either sandbox or production mode:

```objc
ADJEnvironmentSandbox
ADJEnvironmentProduction
```

**Important:** Set the value to `ADJEnvironmentSandbox` if (and only if) you or someone else is testing your app. Make sure to set the environment to `ADJEnvironmentProduction` before you publish the app. Set it back to `ADJEnvironmentSandbox` if you start developing and testing it again.

We use this environment mode to distinguish between real traffic and test traffic from test devices. Keeping the environment updated according to your current status is very important!
 
Adjust SDK emits log messages according to Adobe AEPCore `AEPLogLevel` set by the user. 

## Events tracking

Replace all calls to `ACPCore` (the old Adobe library)

```objc
// Objective-C
// ...
[ACPCore trackAction:ADJAdobeAdjustActionTrackEvent data:];
[ACPCore trackAction:ADJAdobeAdjustActionSetPushToken data:];

```

```swift
// Swift
ACPCore.trackAction(ADJAdobeAdjustActionTrackEvent, data:)
ACPCore.trackAction(ADJAdobeAdjustActionSetPushToken, data:)
``` 

with calls to a `AEPCore` (the new Adobe library) as following:

```objc
// Objective-C
[AEPMobileCore trackAction:ADJAdobeAdjustActionTrackEvent data:];
[AEPMobileCore trackAction:ADJAdobeAdjustActionSetPushToken data:];
```

```swift
// Swift
MobileCore.track(action: ADJAdobeAdjustActionTrackEvent, data:)
MobileCore.track(action: ADJAdobeAdjustActionSetPushToken, data:)
```

## Callback registrations

### Attribution callback

Please replace the following (old) registration code:

```objc
// Objective-C
AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
[config callbackAttributionChanged:^(ADJAttribution * _Nullable attribution) {
    // Attribution response received
}];
[AdjustAdobeExtension registerExtensionWithConfig:config];
```

```swift
// Swift
if let config = AdjustAdobeExtensionConfig.init(environment: ADJEnvironmentSandbox) {
    config.callbackAttributionChanged { (attribution : ADJAttribution?) in
        // Attribution response received
    }
    AdjustAdobeExtension.register(with: config)
}
```

with the followng (new) resgistration code:

```objc
// Objective-C
AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
[config setAttributionChangedBlock:^(ADJAttribution * _Nullable attribution) {
    // Attribution response received
}];
[AdjustAdobeExtension setConfiguration:config];

[AEPMobileCore registerExtensions:@[AdjustAdobeExtension.class]
                       completion:^{
    // Extension's registration completion handler implementation
    // ...
}];
```

```swift
// Swift
if let config = AdjustAdobeExtensionConfig(environment: ADJEnvironmentSandbox) {
    config.setAttributionChangedBlock({ attribution in
        // Attribution response received
    })
    AdjustAdobeExtension.setConfiguration(config)
}

MobileCore.registerExtensions([AdjustAdobeExtension.self]) {
    // Extension's registration completion handler implementation
    // ...
}
```

### Deferred deep linking callback
   
Please replace the following (old) registration code:

```objc
// Objective-C
AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
[config callbackDeeplinkResponse:^BOOL(NSURL * _Nullable deeplink) {
    // Deep link response received
    // Apply your logic to determine whether the Adjust SDK should try to open the deep link
    return YES;
    // or
    // return NO;
}];
[AdjustAdobeExtension registerExtensionWithConfig:config];
```

```swift
// Swift
if let config = AdjustAdobeExtensionConfig.init(environment: ADJEnvironmentSandbox) {
    config.callbackDeeplinkResponse { (deeplink : URL?) in
        // Deep link response received
        // Apply your logic to determine whether the Adjust SDK should try to open the deep link
        return true;
        // or
        // return false;
    }
    AdjustAdobeExtension.register(with: config)
}
```

by the followng (new) resgistration code:

```objc
// Objective-C
AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
[config setDeeplinkResponseBlock:^BOOL(NSURL * _Nullable deeplink) {
    // Deep link response received
    // Apply your logic to determine whether the Adjust SDK should try to open the deep link
    return YES;
    // or
    // return NO;
}];
[AdjustAdobeExtension setConfiguration:config];

[AEPMobileCore registerExtensions:@[AdjustAdobeExtension.class]
                       completion:^{
    // Extension's registration completion handler implementation
    // ...
}];
```

```swift
// Swift
if let config = AdjustAdobeExtensionConfig(environment: ADJEnvironmentSandbox) {
    config.setDeeplinkResponseBlock { deepLink in
        // Deep link response received
        // Apply your logic to determine whether the Adjust SDK should try to open the deep link
        return true;
        // or
        // return false;
    }
    AdjustAdobeExtension.setConfiguration(config)
}

MobileCore.registerExtensions([AdjustAdobeExtension.self]) {
    // Extension's registration completion handler implementation
    // ...
}
```

## Deep linking (reattribution)

**Important:** Please add this new functionality as described below.

Deep links are URLs that direct users to a specific page in your app without any additional navigation. You can use them throughout your marketing funnel to improve user acquisition, engagement, and retention. You can also re-engage your users via deep links which can potentially change their attribution. In order for Adjust to be able to properly reattribute your users via deep links, you need to make sure to pass the deep link to Adjust Adobe extension like desrcribed below (for scheme based deep links and universal links):

```objc
// Objective-C

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return [AdjustAdobeExtension application:app openURL:url options:options];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    return [AdjustAdobeExtension application:application continueUserActivity:userActivity];
}
```

```swift
// Swift

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return AdjustAdobeExtension.application(app, open: url, options: options)
}

func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return AdjustAdobeExtension.application(application, continue: userActivity)
}
```

