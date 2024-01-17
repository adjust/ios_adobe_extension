# Adjust iOS Extension for Adobe Experience Platform SDK

This is the Adjust iOS Extension for Adobe Experience Platform SDK (AEP SDK). You can read more about Adjust™ at [ADJUST Web Page](https://www.adjust.com).

## Table of contents

### [Quick start](#iae-quick-start)
   * [Example app](#iae-example-app)
   * [Add the Adjust Adobe Extension to your project](#iae-sdk-add)
      * [Cocoapods integration](#iae-sdk-add-cocoapods)
      * [Swift Package Manager integration](#iae-sdk-add-spm)
   * [Add iOS frameworks](#iae-sdk-frameworks)
   * [Integrate the Adobe Adjust Extension into your app](#iae-sdk-integrate)
   * [Basic setup](#iae-basic-setup)
   * [Attribution](#iae-attribution)

### [Events tracking](#iae-tracking)
   * [Track event](#iae-track-event)
   * [Track revenue](#iae-track-event-revenue)
   * [Callback parameters](#iae-event-callback-parameters)
   * [Partner parameters](#iae-event-partner-parameters)

### [Additional features](#iae-additional-features)
   * [Attribution callback](#iae-attribution-callback)
   * [Deferred deep linking callback](#iae-deferred-deep-linking-callback)
   * [Push token (uninstall tracking)](#iae-push-token)
   * [Deep Linking (reatribbution)](#iae-deep-link)

## <a id="iae-quick-start"></a>Quick start

### <a id="iae-example-app"></a>Example application

There is an example application inside the [AdjustAdobeExtensionApp](AdjustAdobeExtensionApp/) directory.
Please run `pod install` in this folder to build the example application dependencies and then open `AdjustAdobeExtensionApp.xcworkspace` to test the example application.
Alternatively, you can open `AdjustAdobeExtensionApp.xcodeproj` and integrate an Adjust Adobe Extension using Swift Package Manager as explained [here](#iae-sdk-add-spm)

### <a id="iae-sdk-add"></a>Add the Adjust Adobe Extension to your project

#### <a id="iae-sdk-add-cocoapods"></a>Cocoapods integration

If you're using [CocoaPods](http://cocoapods.org), add the following line to your `Podfile`:

```ruby
pod 'AdjustAdobeExtension'
```

#### <a id="iae-sdk-add-spm"></a>Swift Package Manager integration

If you are using Swift Package Manager, add Adjust Extension for Adobe Experience Platform SDK using the following Github repo link:

```
https://github.com/adjust/ios_adobe_extension.git
```

### <a id="iae-sdk-frameworks"></a>Add iOS frameworks

Adjust SDK is able to get additional information in case you link additional iOS frameworks to your app. Please, add following frameworks in case you want to enable Adjust SDK features based on their presence in your app and mark them as optional:

- `AdSupport.framework` - This framework is needed so that SDK can access to IDFA value and LAT information (prior to iOS 14) .
- `AppTrackingTransparency.framework` - This framework is needed in iOS 14 and later for SDK to be able to wrap user's tracking consent dialog and access to value of the user's consent to be tracked or not.
- `AdServices.framework` - For devices running iOS 14.3 or higher, this framework allows the SDK to automatically handle attribution for ASA campaigns. It is required when leveraging the Apple Ads Attribution API.
- `StoreKit.framework` - This framework is needed for access to `SKAdNetwork` framework and for Adjust SDK to handle communication with it automatically in iOS 14 or later.

### <a id="iae-sdk-integrate"></a>Integrate the Adjust Adobe Extension into your app

Add the following import statement:

```objc
// Objective-C
#import <AdjustAdobeExtension/AdjustAdobeExtension.h>
```

```swift
// Swift
import AdjustAdobeExtension
```

### <a id="iae-basic-setup"></a>Basic setup

First, configure Adjust SDK Extension in Adobe Experience Platform portal - provide an `Adjust App Token` (you can get it at [Adjust dashboard](https://dash.adjust.com/)) and choose whether to [Share attribution data with Adobe](#iae-attribution) using the toggle. 

Then register the Adjust Adobe Extension like in the following code snippet.

- Replace `{your_adobe_app_id}` with your `Unique identifier assigned to the app instance by Adobe Launch Portal`.
- Set the `{environment}` to either sandbox or production mode:
```objc
ADJEnvironmentSandbox
ADJEnvironmentProduction
```

**Important:** Set the value to `ADJEnvironmentSandbox` if (and only if) you or someone else is testing your app. Make sure to set the environment to `ADJEnvironmentProduction` before you publish the app. Set it back to `ADJEnvironmentSandbox` if you start developing and testing it again.

We use this environment mode to distinguish between real traffic and test traffic from test devices. Keeping the environment updated according to your current status is very important!
 
Adjust SDK emits log messages according to Adobe AEPCore `AEPLogLevel` set by the user. 

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


### <a id="iae-attribution"></a>Attribution

The option to share attribution data with Adobe is in the Launch dashboard under the extensions configuration and it is on by default. Adjust tracks the action name `Adjust Campaign Data Received` with the following attribution information from Adjust:

* `Adjust Network`
* `Adjust Campaign`
* `Adjust AdGroup`
* `Adjust Creative`

## <a id="iae-tracking"></a>Events tracking

### <a id="iae-track-event"></a>Track event

You can use Adobe `[AEPMobileCore trackAction:]` API for [`event tracking`](https://help.adjust.com/en/article/record-events-ios-sdk). Suppose you want to track every tap on a button. To do so, you'll create a new event token in your [Adjust dashboard](https://dash.adjust.com/). Let's say that the event token is `abc123`. In your button's press handling method, add the following lines to track the click:

```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"abc123" forKey:ADJAdobeAdjustEventToken];
[AEPMobileCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];
```

```swift
// Swift
var dataDict: Dictionary = [String : String]()
dataDict[ADJAdobeAdjustEventToken] = "abc123"
MobileCore.track(action: ADJAdobeAdjustActionTrackEvent, data: dataDict)
```

### <a id="iae-track-event-revenue"></a>Track revenue

If your users can generate revenue by tapping on advertisements or making in-app purchases, you can track those revenues too with events. Let's say a tap is worth one Euro cent. You can track the revenue event like this:

```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"abc123" forKey:ADJAdobeAdjustEventToken];
[dataDict setValue:@"0.01" forKey:ADJAdobeAdjustEventRevenue];
[dataDict setValue:@"EUR" forKey:ADJAdobeAdjustEventCurrency];
[AEPMobileCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];
```

```swift
// Swift
var dataDict: Dictionary = [String : String]()
dataDict[ADJAdobeAdjustEventToken] = "abc123"
dataDict[ADJAdobeAdjustEventRevenue] = "0.01"
dataDict[ADJAdobeAdjustEventCurrency] = "EUR"
MobileCore.track(action: ADJAdobeAdjustActionTrackEvent, data: dataDict)
```

### <a id="iae-event-callback-parameters"></a>Callback parameters

You can register a callback URL for your events in your [dashboard](https://dash.adjust.com/). We will send a GET request to that URL whenever the event is tracked. You can add callback parameters to that event by adding them as key value pair to the context data map before tracking it. We will then append these parameters to your callback URL.

For example, suppose you have registered the URL `https://www.mydomain.com/callback` then track an event like this:

```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"abc123" forKey:ADJAdobeAdjustEventToken];
[dataDict setValue:@"value1" forKey:[ADJAdobeAdjustEventCallbackParamPrefix stringByAppendingString:@"key1"]];
[dataDict setValue:@"value2" forKey:[ADJAdobeAdjustEventCallbackParamPrefix stringByAppendingString:@"key2"]];
[AEPMobileCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];
```

```swift
// Swift
var dataDict: Dictionary = [String : String]()
dataDict[ADJAdobeAdjustEventToken] = "abc123"
dataDict[ADJAdobeAdjustEventCallbackParamPrefix.appending("key1")] = "value1"
dataDict[ADJAdobeAdjustEventCallbackParamPrefix.appending("key2")] = "value2"
MobileCore.track(action: ADJAdobeAdjustActionTrackEvent, data: dataDict)
```

In that case we would track the event and send a request to:

```
http://www.mydomain.com/callback?key1=value1&key2=value2
```

It should be mentioned that we support a variety of placeholders like `{idfa}` that can be used as parameter values. In the resulting callback this placeholder would be replaced with the ID for Advertisers of the current device. Also note that we don't store any of your custom parameters, but only append them to your callbacks, thus without a callback they will not be saved nor sent to you.

You can read more about using URL callbacks, including a full list of available values, in our [callbacks guide](https://help.adjust.com/en/article/callbacks-partner).

### <a id="iae-event-partner-parameters"></a>Partner parameters

You can also add parameters to be transmitted to network partners, which have been activated in your Adjust dashboard.

You can add partner parameters to that event by adding them as key value pair to the context data map before tracking it.

```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"abc123" forKey:ADJAdobeAdjustEventToken];
[dataDict setValue:@"value1" forKey:[ADJAdobeAdjustEventPartnerParamPrefix stringByAppendingString:@"key1"]];
[dataDict setValue:@"value2" forKey:[ADJAdobeAdjustEventPartnerParamPrefix stringByAppendingString:@"key2"]];
[AEPMobileCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];
```

```swift
// Swift
var dataDict: Dictionary = [String : String]()
dataDict[ADJAdobeAdjustEventToken] = "abc123"
dataDict[ADJAdobeAdjustEventPartnerParamPrefix.appending("key1")] = "value1"
dataDict[ADJAdobeAdjustEventPartnerParamPrefix.appending("key2")] = "value2"
MobileCore.track(action: ADJAdobeAdjustActionTrackEvent, data: dataDict)
```

You can read more about special partners and these integrations in our [guide to special partners](https://help.adjust.com/en/classic/integrated-partners-classic).

## <a id="iae-additional-features"></a>Additional features

Once you have integrated the Adjust iOS Extension for Adobe Experience Platform SDK into your project, you can take advantage of the following features:

### <a id="iae-attribution-callback"></a>Attribution callback

You can register a callback code block to be notified on tracker attribution changes. Due to the different sources we consider for attribution, we cannot provide this information synchronously.

Please see our [attribution data policies](https://github.com/adjust/sdks/blob/master/doc/attribution-data.md) for more information.

With the extension config instance, add the attribution callback code block to the Adjust extension before you register it (together with other Adobe extensions you possibly use) in Adobe Experience Platform Core SDK:

```objc
// Objective-C
AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
[config setAttributionChangedBlock:^(ADJAttribution * _Nullable attribution) {
    // Attribution response received
}];
[AdjustAdobeExtension setConfiguration:config];

[AEPMobileCore registerExtensions:@[AdjustAdobeExtension.class]
                       completion:^{
    // Extensions registration completion handler implementation
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
    // Extensions registration completion handler implementation
    // ...
}
```

The code block is called after the SDK receives the final attribution data. Within the block body, you'll have an access to the `attribution` parameter.

### <a id="iae-deferred-deep-linking-callback"></a>Deferred deep linking callback

The Adjust SDK opens the deferred deep link by default. There is no extra configuration needed. But if you wish to control whether the Adjust SDK will open the deferred deep link or not, you can do it with an appropriate callback code block in the config object.

With the extension config instance, add the deferred deep linking callback block to the Adjust extension before you register it (together with other Adobe extensions you possibly use) in Adobe Experience Platform Core SDK:

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
    // Extension registration completion handler implementation
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
    // Extension registration completion handler implementation
    // ...
}
```

After the Adjust SDK receives the deep link information from our backend, the SDK will deliver you its content via the callback block and expect the boolean return value from you. This return value represents your decision on whether the Adjust SDK should open the deep link or not.

### <a id="iae-push-token"></a>Push token (uninstall tracking)

Push tokens are used for Audience Builder and client callbacks; they are also required for uninstall and reinstall tracking.

To send us the APNs push notification token, add the following call to Adjust once you have obtained your token (or whenever its value changes):

```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"{your_app_push_token}" forKey:ADJAdobeAdjustPushToken];
[AEPMobileCore trackAction:ADJAdobeAdjustActionSetPushToken data:dataDict];
```

```swift
// Swift
var dataDict = [String:String]();
dataDict = [ADJAdobeAdjustPushToken:"{your_app_push_token}"]
MobileCore.track(action: ADJAdobeAdjustActionSetPushToken, data: dataDict)
```


### <a id="iae-deep-link"></a>Deep Linking (reattribution)
TBD: We have to add a section for forwarding the following Application calls to the Adjust SDK for checking a deep link URL for attribution data and send it to the Adjust backend for reattribution.

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
