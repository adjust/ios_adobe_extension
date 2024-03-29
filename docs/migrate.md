# Migrate Adjust iOS Extension for Adobe Experience Platform SDK from v1.1.1 to v2.0.0

## Adjust iOS Extension for Adobe Experience Platform SDK documentation

Refer to the [this document](../README.md) as a general integration information source.

## Update Adjust Adobe extension dependency

### Cocoapods

Run this command at the level of your `Podfile`:

```
> pod update
```

### Swift Package Manager

Go to the Xcode->[File]->[Packages]->[Update to Latest Package Versions]

## Deprecated iOS Frameworks

You can remove `iAd.framework` if you haven't done this already due to its [phased out state](https://developer.apple.com/documentation/iad?language=objc). 

## Adjust Adobe Extension initialization

Replace this (old) initialization code:

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

## Events tracking

Replace all calls to `ACPCore` (the old Adobe library):

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

Replace the following (old) registration code:

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

with the following (new) registration code:

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
   
Replace the following (old) registration code:

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

by the following (new) registration code:

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

Version 2.0.0 introduces an ability to pass information about the deep link that has opened your app in order to potentially change the attribution source. Make sure to read and integrate this functionality in accordance to the [Deep Linking (reattribution)](../README.md#iae-deep-linking) section of the README.
