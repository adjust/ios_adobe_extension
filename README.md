# Adjust SDK Extension

## <a id="sdk-add"></a>Add the SDK to your project

If you're using [CocoaPods][http://cocoapods.org], add the following line to your `Podfile` and continue from [this step](#sdk-integrate):

```ruby
pod 'AdjustAdobeExtension'
```

### <a id="sdk-integrate"></a>Integrate the SDK into your app

If you added the Adjust SDK via a Pod repository, add the following import statement:

```objc
#import "AdjustAdobeExtension.h"
```

### <a id="basic-setup"></a>Basic setup

You don't need to start the Adjust SDK manually. First, set the configuration in [Launch dashboard](https://launch.adobe.com/) and initialize `ACPCore`, then register the Adjust SDK Extension:

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [ACPCore configureWithAppId:@"..."];
    
    // ...
    
    AdjustAdobeExtensionConfig *config = [AdjustAdobeExtensionConfig configWithEnvironment:ADJEnvironmentSandbox];
    [AdjustAdobeExtension registerExtensionWithConfig:config];
    
    return YES;
}
```

#### Delegate callback

Optional: If you want to receive any of the delegate callbacks, you can register for the callbacks in `AdjustAdobeExtensionConfig`:

```objc
[config callbackEventTrackingSucceeded:^(ADJEventSuccess * _Nullable eventSuccessResponseData) {
    // event tracked
}];
```

### Tracking events

Any event (action or state) tracked using `ACPCore` is tracked by Adjust if it contains the `adj.eventToken` key:

```objc
[ACPCore trackAction:@"TestAction" data:@{@"a": @"b", @"adj.eventToken": @"abc123"}];
[ACPCore trackState:@"TestState" data:@{@"a": @"b"}]; // will *not* be tracked by Adjust
```

If the event contains the `revenue` and `currency` keys, the event is tracked with this information as well.

### Attribution

The option to share attribution data with Adobe is under Extensions and is on by default. Adjust tracks the action name `Adjust Attribution Data` with attribution information from Adjust for keys prefixed with `adjust`.





