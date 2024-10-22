//
//  ViewController.m
//  AdjustAdobeExtensionApp
//
//  Created by Adjust SDK Team on 21.11.23.
//

#import "ViewController.h"
@import AEPCore;
#import <AdjustAdobeExtension/AdjustAdobeExtension.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Track simple event
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:@"g3mfiw" forKey:ADJAdobeAdjustEventToken];
    [AEPMobileCore trackAction:ADJAdobeAdjustActionTrackEvent
                          data:dataDict];
    [dataDict removeAllObjects];

    // Track Revenue event
    [dataDict setValue:@"a4fd35" forKey:ADJAdobeAdjustEventToken];
    [dataDict setValue:@"1.0" forKey:ADJAdobeAdjustEventRevenue];
    [dataDict setValue:@"EUR" forKey:ADJAdobeAdjustEventCurrency];
    [AEPMobileCore trackAction:ADJAdobeAdjustActionTrackEvent
                          data:dataDict];
    [dataDict removeAllObjects];

    // Track event with Callback parameters
    [dataDict setValue:@"34vgg9" forKey:ADJAdobeAdjustEventToken];
    [dataDict setValue:@"value1" forKey:[ADJAdobeAdjustEventCallbackParamPrefix stringByAppendingString:@"key1"]];
    [dataDict setValue:@"value2" forKey:[ADJAdobeAdjustEventCallbackParamPrefix stringByAppendingString:@"key2"]];
    [AEPMobileCore trackAction:ADJAdobeAdjustActionTrackEvent
                          data:dataDict];
    [dataDict removeAllObjects];

    // Track event with Partner parameters
    [dataDict setValue:@"w788qs" forKey:ADJAdobeAdjustEventToken];
    [dataDict setValue:@"value1" forKey:[ADJAdobeAdjustEventPartnerParamPrefix stringByAppendingString:@"key1"]];
    [dataDict setValue:@"value2" forKey:[ADJAdobeAdjustEventPartnerParamPrefix stringByAppendingString:@"key2"]];
    [AEPMobileCore trackAction:ADJAdobeAdjustActionTrackEvent
                          data:dataDict];
    [dataDict removeAllObjects];

    // Set Push Token
    [dataDict setValue:@"your_app_push_token" forKey:ADJAdobeAdjustPushToken];
    [AEPMobileCore trackAction:ADJAdobeAdjustActionSetPushToken
                          data:dataDict];
    [dataDict removeAllObjects];

    // Add Global Partner Parameters
    [Adjust addGlobalPartnerParameter:@"value1" forKey:@"key1"];
    [Adjust addGlobalPartnerParameter:@"value2" forKey:@"key2"];

    // Add Global Callback Parameters
    [Adjust addGlobalCallbackParameter:@"value1" forKey:@"key1"];
    [Adjust addGlobalCallbackParameter:@"value2" forKey:@"key2"];

}

@end
