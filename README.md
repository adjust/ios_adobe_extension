# Adjust Extension for Adobe Experience SDK

## <a id="sdk-add"></a>Add the Adjust Extension to your project

### <a id="sdk-add-cocoapods"></a>Cocoapods integration

If you're using [CocoaPods](http://cocoapods.org), add the following line to your `Podfile` and continue from [this step](#sdk-integrate):

```ruby
pod 'AdjustAdobeExtension'
```

### <a id="sdk-add-spm"></a>Swift Package Manager integration

If you are using Swift Package Manager, add Adjust Extension for Adobe Experience SDK using the following Github repo link:

```
https://github.com/adjust/ios_adobe_extension.git
```

Currently, Adjust Extension uses the latest version of Adobe Experience Platform SDKs [ACP SDKs](https://github.com/Adobe-Marketing-Cloud/acp-sdks).
Due to a missing SPM support in Adobe ACP SDKs, all required Adobe frameworks are part of Adjust Extension release.

In the Frameworks, Libraries, and Embedded Content section of your App target's General tab, add the following frameworks and libraries required for Adobe frameworks: `UIKit`, `SystemConfiguration`, `WebKit`, `UserNotifications`, `libsqlite3.0`, `libc++`, `libz`.

## <a id="sdk-frameworks"></a>Add iOS frameworks

Adjust SDK is able to get additional information in case you link additional iOS frameworks to your app. Please, add following frameworks in case you want to enable Adjust SDK features based on their presence in your app and mark them as optional:

- `AdSupport.framework` - This framework is needed so that SDK can access to IDFA value and (prior to iOS 14) LAT information.
- `iAd.framework` - This framework is needed so that SDK can automatically handle attribution for ASA campaigns you might be running.
- `AdServices.framework` - For devices running iOS 14.3 or higher, this framework allows the SDK to automatically handle attribution for ASA campaigns. It is required when leveraging the Apple Ads Attribution API.
- `CoreTelephony.framework` - This framework is needed so that SDK can determine current radio access technology.
- `StoreKit.framework` - This framework is needed for access to `SKAdNetwork` framework and for Adjust SDK to handle communication with it automatically in iOS 14 or later.
- `AppTrackingTransparency.framework` - This framework is needed in iOS 14 and later for SDK to be able to wrap user's tracking consent dialog and access to value of the user's consent to be tracked or not.

## <a id="sdk-integrate"></a>Integrate the Adjust Extension into your app

Add the following import statement:

Objective-C:
```objc
#import <AdjustAdobeExtension/AdjustAdobeExtension.h>
```

Swift:
```swift
import AdjustAdobeExtension
```

## <a id="basic-setup"></a>Basic setup

You don't need to start the Adjust Adjust Extension manually. First, set the configuration in [Launch dashboard](https://launch.adobe.com/) and initialize `ACPCore`, then register the Adjust Extension:

Objective-C:
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ACPCore configureWithAppId:@"..."];
    
    // ...
    
    AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
    [AdjustAdobeExtension registerExtensionWithConfig:config];
    
    return YES;
}
```

Swift:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    ACPCore.configure(withAppId: "...")

    // ...

    if let config = AdjustAdobeExtensionConfig.init(environment: ADJEnvironmentSandbox) {
        AdjustAdobeExtension.register(with: config)
    }

    return true
}
```


### <a id="delegates-callback"></a>Delegates callback

Optional: If you want to receive the attribution and deep link delegates callback, you can register for it in `AdjustAdobeExtensionConfig`:

Objective-C:
```objc
[config callbackDeeplinkResponse:^BOOL(NSURL * _Nullable deeplink) {
    // deep link response received

    // Apply your logic to determine whether the Adjust SDK should try to open the deep link
    return YES;
    // or
    // return NO;
}];

[config callbackAttributionChanged:^(ADJAttribution * _Nullable attribution) {
    // attribution response received
}];
```

Swift:
```swift
config.callbackDeeplinkResponse { (deeplink : URL?) in
    // deep link response received

    // Apply your logic to determine whether the Adjust SDK should try to open the deep link
    return true;
    // or
    // return false;
}

config.callbackAttributionChanged { (attribution : ADJAttribution?) in
    // attribution response received
}


```

## <a id="tracking-events"></a>Tracking events

Any event (action or state) tracked using `ACPCore` is tracked by Adjust if it contains the `ADJAdobeAdjustEventCurrency` constant as a key:

Objective-C"
```objc
[ACPCore trackAction:@"TestAction" data:@{@"a": @"b", ADJAdobeAdjustEventToken: @"abc123"}];
[ACPCore trackState:@"TestState" data:@{@"a": @"b"}]; // will *not* be tracked by Adjust
```

Swift:
```swift
ACPCore.trackAction("TestAction", data: ["a": "b", ADJAdobeAdjustEventToken: "abc123"])
ACPCore.trackState("TestState", data: ["a": "b"])  // will *not* be tracked by Adjust

```

If the event contains the constants `ADJAdobeAdjustEventCurrency` and `ADJAdobeAdjustEventRevenue` as keys, the event is tracked with this information as well.

## <a id="attribution"></a>Attribution

The option to share attribution data with Adobe is in the Launch dashboard under the extensions configuration and is on by default. Adjust tracks the action name `Adjust Campaign Data Received` with the following attribution information from Adjust:

* `Adjust Network`
* `Adjust Campaign`
* `Adjust AdGroup`
* `Adjust Creative`
