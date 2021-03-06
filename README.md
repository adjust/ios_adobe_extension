# Adjust Extension for Adobe Experience SDK

## <a id="sdk-add"></a>Add the Adjust Extension to your project

If you're using [CocoaPods](http://cocoapods.org), add the following line to your `Podfile` and continue from [this step](#sdk-integrate):

```ruby
pod 'AdjustAdobeExtension'
```

### <a id="sdk-integrate"></a>Integrate the Adjust Extension into your app

If you added the Adjust SDK via a Pod repository, add the following import statement:

```objc
#import <AdjustAdobeExtension/AdjustAdobeExtension.h>
```

### <a id="basic-setup"></a>Basic setup

You don't need to start the Adjust Adjust Extension manually. First, set the configuration in [Launch dashboard](https://launch.adobe.com/) and initialize `ACPCore`, then register the Adjust Extension:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [ACPCore configureWithAppId:@"..."];
    
    // ...
    
    AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
    [AdjustAdobeExtension registerExtensionWithConfig:config];
    
    return YES;
}
```

#### Delegates callback

Optional: If you want to receive the attribution and deep link delegates callback, you can register for it in `AdjustAdobeExtensionConfig`:

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

### Tracking events

Any event (action or state) tracked using `ACPCore` is tracked by Adjust if it contains the `ADJAdobeAdjustEventCurrency` constant as a key:

```objc
[ACPCore trackAction:@"TestAction" data:@{@"a": @"b", ADJAdobeAdjustEventToken: @"abc123"}];
[ACPCore trackState:@"TestState" data:@{@"a": @"b"}]; // will *not* be tracked by Adjust
```

If the event contains the constants `ADJAdobeAdjustEventCurrency` and `ADJAdobeAdjustEventRevenue` as keys, the event is tracked with this information as well.

### Attribution

The option to share attribution data with Adobe is in the Launch dashboard under the extensions configuration and is on by default. Adjust tracks the action name `Adjust Campaign Data Received` with the following attribution information from Adjust:

* `Adjust Network`
* `Adjust Campaign`
* `Adjust AdGroup`
* `Adjust Creative`
