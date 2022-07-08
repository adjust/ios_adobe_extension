# Adjust Extension for Adobe Experience SDK

This is the iOS Adobe Mobile Extension of Adjust™. You can read more about Adjust™ at [adjust.com].

## Table of contents

### [Quick start](#iae-quick-start)
   * [Example app](#iae-example-app)
   * [Add the Adjust Extension to your project](#iae-sdk-add)
      * [Cocoapods integration](#iae-sdk-add-cocoapods)
      * [Swift Package Manager integration](#iae-sdk-add-spm)
   * [Integrate the Adjust Extension into your app](#iae-sdk-integrate)
   * [Basic setup](#iae-basic-setup)
   * [Session tracking](#iae-session-tracking)
   * [Attribution](#iae-attribution)
   * [Add iOS frameworks](#iae-sdk-frameworks)

### [Events tracking](#iae-tracking)
   * [Track event](#iae-track-event)
   * [Track revenue](#iae-track-event-revenue)

### [Custom parameters](#iae-custom-parameters)
   * [Custom parameters overview](#iae-custom-parameters-overview)
   * [Event parameters](#iae-event-parameters)
      * [Event callback parameters](#iae-event-callback-parameters)
      * [Event partner parameters](#iae-event-partner-parameters)

### [Additional features](#iae-additional-features)
   * [Attribution callback](#iae-attribution-callback)
   * [Deferred deep linking callback](#iae-deferred-deep-linking-callback)
   * [Push token (uninstall tracking)](#iae-push-token)

## <a id="iae-quick-start"></a>Quick start

### <a id="iae-example-app"></a>Example app

There is an example app inside the [Example][example-app] directory.
Please run `pod install` in this folder to build the example application dependencies and then open `AdjustAdobeExtension.xcworkspace` to test the example application.

## <a id="iae-sdk-add"></a>Add the Adjust Extension to your project

### <a id="iae-sdk-add-cocoapods"></a>Cocoapods integration

If you're using [CocoaPods](http://cocoapods.org), add the following line to your `Podfile` and continue from [this step](#iae-sdk-integrate):

```ruby
pod 'AdjustAdobeExtension'
```

### <a id="iae-sdk-add-spm"></a>Swift Package Manager integration

If you are using Swift Package Manager, add Adjust Extension for Adobe Experience SDK using the following Github repo link:

```
https://github.com/adjust/ios_adobe_extension.git
```

Currently, Adjust Extension uses the latest version of Adobe Experience Platform SDKs [ACP SDKs](https://github.com/Adobe-Marketing-Cloud/acp-sdks).
Due to a missing SPM support in Adobe ACP SDKs, all required Adobe frameworks are part of Adjust Extension release.

In the `Frameworks, Libraries, and Embedded Content` section of your App target's `General` tab, add the following frameworks and libraries required for Adobe frameworks: `UIKit`, `SystemConfiguration`, `WebKit`, `UserNotifications`, `libsqlite3.0`, `libc++`, `libz`.

## <a id="iae-sdk-integrate"></a>Integrate the Adjust Extension into your app

Add the following import statement:

```objc
// Objective-C
#import <AdjustAdobeExtension/AdjustAdobeExtension.h>
```

```swift
// Swift
import AdjustAdobeExtension
```

## <a id="iae-basic-setup"></a>Basic setup

You don't need to start the Adjust Extension manually. First, set the configuration in [Launch dashboard](https://launch.adobe.com/) and initialize `ACPCore`, then register the Adjust Extension:

```objc
// Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [ACPCore setLogLevel:ACPMobileLogLevelVerbose];
    [ACPCore configureWithAppId:@"{your_adobe_app_id}"];
    
    AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
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

    if let config = AdjustAdobeExtensionConfig.init(environment: ADJEnvironmentSandbox) {
        AdjustAdobeExtension.register(with: config)
    }

    ACPCore.start {
        ACPCore.lifecycleStart(nil)
    }
    return true
}
```

Replace `{your_adobe_app_id}` with your app id from Adobe Launch.

Next, you must set the `environment` to either sandbox or production mode:

```objc
ADJEnvironmentSandbox
ADJEnvironmentProduction
```

**Important:** Set the value to `ADJEnvironmentSandbox` if (and only if) you or someone else is testing your app. Make sure to set the environment to `ADJEnvironmentProduction` before you publish the app. Set it back to `ADJEnvironmentSandbox` if you start developing and testing it again.

We use this environment to distinguish between real traffic and test traffic from test devices. Keeping the environment updated according to your current status is very important!

## <a id="iae-session-tracking"></a>Session tracking

Adjust SDK can track sessions in your app based on Activity lifecycle.

## <a id="iae-attribution"></a>Attribution

The option to share attribution data with Adobe is in the Launch dashboard under the extensions configuration and is on by default. Adjust tracks the action name `Adjust Campaign Data Received` with the following attribution information from Adjust:

* `Adjust Network`
* `Adjust Campaign`
* `Adjust AdGroup`
* `Adjust Creative`

## <a id="iae-sdk-frameworks"></a>Add iOS frameworks

Adjust SDK is able to get additional information in case you link additional iOS frameworks to your app. Please, add following frameworks in case you want to enable Adjust SDK features based on their presence in your app and mark them as optional:

- `AdSupport.framework` - This framework is needed so that SDK can access to IDFA value and (prior to iOS 14) LAT information.
- `iAd.framework` - This framework is needed so that SDK can automatically handle attribution for ASA campaigns you might be running.
- `AdServices.framework` - For devices running iOS 14.3 or higher, this framework allows the SDK to automatically handle attribution for ASA campaigns. It is required when leveraging the Apple Ads Attribution API.
- `StoreKit.framework` - This framework is needed for access to `SKAdNetwork` framework and for Adjust SDK to handle communication with it automatically in iOS 14 or later.
- `AppTrackingTransparency.framework` - This framework is needed in iOS 14 and later for SDK to be able to wrap user's tracking consent dialog and access to value of the user's consent to be tracked or not.

## <a id="iae-tracking"></a>Events tracking

### <a id="iae-track-event"></a>Track event

You can use Adobe `[ACPCore trackAction:]` API for [`event tracking`][event-tracking]. Suppose you want to track every tap on a button. To do so, you'll create a new event token in your [dashboard]. Let's say that the event token is `abc123`. In your button's press handling method, add the following lines to track the click:

```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"abc123" forKey:ADJAdobeAdjustEventToken];
[ACPCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];
```

```swift
// Swift
var dataDict: Dictionary = [String : String]()
dataDict[ADJAdobeAdjustEventToken] = "abc123"
ACPCore.trackAction(ADJAdobeAdjustActionTrackEvent, data: dataDict)
```

### <a id="iae-track-event-revenue"></a>Track revenue

If your users can generate revenue by tapping on advertisements or making in-app purchases, you can track those revenues too with events. Let's say a tap is worth one Euro cent. You can track the revenue event like this:

```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"abc123" forKey:ADJAdobeAdjustEventToken];
[dataDict setValue:@"0.01" forKey:ADJAdobeAdjustEventRevenue];
[dataDict setValue:@"EUR" forKey:ADJAdobeAdjustEventCurrency];
[ACPCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];
```

```swift
// Swift
var dataDict: Dictionary = [String : String]()
dataDict[ADJAdobeAdjustEventToken] = "abc123"
dataDict[ADJAdobeAdjustEventRevenue] = "0.01"
dataDict[ADJAdobeAdjustEventCurrency] = "EUR"
ACPCore.trackAction(ADJAdobeAdjustActionTrackEvent, data: dataDict)
```

## <a id="iae-custom-parameters"></a>Custom parameters

### <a id="iae-custom-parameters-overview"></a>Custom parameters overview

In addition to the data points the Adjust SDK collects by default, you can use the extension to track and add as many custom values as you need (user IDs, product IDs, etc.) to the event or session. Custom parameters are only available as raw data and will **not** appear in your Adjust dashboard.

You should use **callback parameters** for the values you collect for your own internal use, and **partner parameters** for those you share with external partners. If a value (e.g. product ID) is tracked both for internal use and external partner use, we recommend you track it with both callback and partner parameters.


### <a id="iae-event-parameters"></a>Event parameters

### <a id="iae-event-callback-parameters"></a>Event callback parameters

You can register a callback URL for your events in your [dashboard]. We will send a GET request to that URL whenever the event is tracked. You can add callback parameters to that event by adding them as key value pair to the context data map before tracking it. We will then append these parameters to your callback URL.

For example, if you've registered the URL `http://www.example.com/callback`, then you would track an event like this:

```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"abc123" forKey:ADJAdobeAdjustEventToken];
[dataDict setValue:@"value1" forKey:[ADJAdobeAdjustEventCallbackParamPrefix stringByAppendingString:@"key1"]];
[dataDict setValue:@"value2" forKey:[ADJAdobeAdjustEventCallbackParamPrefix stringByAppendingString:@"key2"]];
[ACPCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];
```

```swift
// Swift
var dataDict: Dictionary = [String : String]()
dataDict[ADJAdobeAdjustEventToken] = "abc123"
dataDict[ADJAdobeAdjustEventCallbackParamPrefix.appending("key1")] = "value1"
dataDict[ADJAdobeAdjustEventCallbackParamPrefix.appending("key2")] = "value2"
ACPCore.trackAction(ADJAdobeAdjustActionTrackEvent, data: dataDict)
```


In this case we would track the event and send a request to:

```
http://www.example.com/callback?key1=value1&key2=value2
```

Adjust supports a variety of placeholders, which can be used as parameter values. In the resulting callback, we would replace the placeholder with an appropriate value. Please note that we don't store any of your custom parameters. We **only** append them to your callbacks. If you haven't registered a callback for an event, we will not even read these parameters.

You can read more about URL callbacks (including a full list of available values) in our [callbacks guide][callbacks-guide].

### <a id="iae-event-partner-parameters"></a>Event partner parameters

When your parameters are activated in the Adjust dashboard, you have the option to transmit them to your network partners.

This works similarly to the callback parameters mentioned above;


```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"abc123" forKey:ADJAdobeAdjustEventToken];
[dataDict setValue:@"value1" forKey:[ADJAdobeAdjustEventPartnerParamPrefix stringByAppendingString:@"key1"]];
[dataDict setValue:@"value2" forKey:[ADJAdobeAdjustEventPartnerParamPrefix stringByAppendingString:@"key2"]];
[ACPCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];
```

```swift
// Swift
var dataDict: Dictionary = [String : String]()
dataDict[ADJAdobeAdjustEventToken] = "abc123"
dataDict[ADJAdobeAdjustEventPartnerParamPrefix.appending("key1")] = "value1"
dataDict[ADJAdobeAdjustEventPartnerParamPrefix.appending("key2")] = "value2"
ACPCore.trackAction(ADJAdobeAdjustActionTrackEvent, data: dataDict)
```

You can read more about special partners and these integrations in our [guide to special partners][special-partners].

## <a id="iae-additional-features"></a>Additional features

Once you have integrated the Adjust Extension for Adobe Experience SDK into your project, you can take advantage of the following features:

### <a id="iae-attribution-callback"></a>Attribution callback

You can register a callback code block to be notified of tracker attribution changes. Due to the different sources we consider for attribution, we cannot provide this information synchronously.

Please see our [attribution data policies][attribution-data] for more information.

With the extension config instance, add the attribution callback before you start the SDK:

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

The code block is called after the SDK receives the final attribution data. Within the block body, you'll have an access to the `attribution` parameter.

### <a id="iae-deferred-deep-linking-callback"></a>Deferred deep linking callback

The Adjust SDK opens the deferred deep link by default. There is no extra configuration needed. But if you wish to control whether the Adjust SDK will open the deferred deep link or not, you can do it with a callback code block in the config object.

With the extension config instance, add the deferred deep linking callback block before you start the SDK:

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

After the Adjust SDK receives the deep link information from our backend, the SDK will deliver you its content via the callback block and expect the boolean return value from you. This return value represents your decision on whether or not the Adjust SDK should launch the activity to which you have assigned the scheme name from the deeplink.

### <a id="iae-push-token"></a>Push token (uninstall tracking)

Push tokens are used for Audience Builder and client callbacks; they are also required for uninstall and reinstall tracking.

To send us the push notification token, add the following call to Adjust once you have obtained your token (or whenever its value changes):

```objc
// Objective-C
NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
[dataDict setValue:@"your_app_push_token" forKey:ADJAdobeAdjustPushToken];
[ACPCore trackAction:ADJAdobeAdjustActionSetPushToken data:dataDict];
```

```swift
// Swift
var dataDict: Dictionary = [String : String]()
dataDict[ADJAdobeAdjustPushToken] = "your_app_push_token"
ACPCore.trackAction(ADJAdobeAdjustActionSetPushToken, data: dataDict)
```

[example-app]:          Example/
[event-tracking]:       https://docs.adjust.com/en/event-tracking
[dashboard]:            http://dash.adjust.com/
[callbacks-guide]:      https://docs.adjust.com/en/callbacks
[special-partners]:     https://docs.adjust.com/en/special-partners
[attribution-data]:     https://github.com/adjust/sdks/blob/master/doc/attribution-data.md
