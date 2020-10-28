# AdjustAdobeExtension

## <a id="sdk-add"></a>Add the SDK to your project

If you're using [CocoaPods][cocoapods], add the following line to your `Podfile` and continue from [this step](#sdk-integrate):

```ruby
pod 'AdjustAdobeExtension'
```

### <a id="sdk-integrate"></a>Integrate the SDK into your app

If you added the Adjust SDK via a Pod repository, add the following import statements:

```objc
#import "AdjustAdobeExtension.h"
```

### <a id="basic-setup"></a>Basic setup

You don't need to start the Adjust SDK manually. After setting the configurations in [Launch dashboard](https://launch.adobe.com/) and initializing `ACPCore`, register the Adjust SDK Extension:

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

#### Delegates callback

If you want to receive any of the delegates callbacks, you can optionally register for the callbacks in `AdjustAdobeExtensionConfig`:

```objc
[config callbackEventTrackingSucceeded:^(ADJEventSuccess * _Nullable eventSuccessResponseData) {
    // event tracked
}];
```

### Tracking events

Any events (action or state) tracked using `ACPCore` is tracked by Adjust if it contains the key `adj.eventToken`:

```objc
[ACPCore trackAction:@"TestAction" data:@{@"a": @"b", @"adj.eventToken": @"abc123"}];
[ACPCore trackState:@"TestState" data:@{@"a": @"b"}]; // will *not* be tracked by Adjust
```

If it contains the keys `revenue` and `currency`, the event is tracked with this information as well.

### Attribution

In case the option to share attribution to Adobe is enabled in the extension configuration, Adjust will track an action name `Adjust Attribution Data` with the attribution information from Adjust where the keys will be prefixed with `adjust.`





