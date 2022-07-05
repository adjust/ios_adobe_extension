//
//  ADJViewController.h
//  AdjustAdobeExtension
//
//  Created by Ricardo Carvalho (@rabc) on 09/04/2020.
//  Copyright (c) 2020 Adjust GmbH. All rights reserved.
//

#import "ADJViewController.h"
#import "ACPCore.h"
#import <AdjustAdobeExtension/AdjustAdobeExtension.h>

@interface ADJViewController ()

@end

@implementation ADJViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Track simple event
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    [dataDict setValue:@"g3mfiw" forKey:ADJAdobeAdjustEventToken];
    [ACPCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];

    [dataDict removeAllObjects];

    // Track Revenue event
    [dataDict setValue:@"a4fd35" forKey:ADJAdobeAdjustEventToken];
    [dataDict setValue:@"1.0" forKey:ADJAdobeAdjustEventRevenue];
    [dataDict setValue:@"EUR" forKey:ADJAdobeAdjustEventCurrency];
    [ACPCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];

    [dataDict removeAllObjects];

    // Track event with Callback parameters
    [dataDict setValue:@"34vgg9" forKey:ADJAdobeAdjustEventToken];
    [dataDict setValue:@"value1" forKey:[ADJAdobeAdjustEventCallbackParamPrefix stringByAppendingString:@"key1"]];
    [dataDict setValue:@"value2" forKey:[ADJAdobeAdjustEventCallbackParamPrefix stringByAppendingString:@"key2"]];
    [ACPCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];

    [dataDict removeAllObjects];

    // Track event with Partner parameters
    [dataDict setValue:@"w788qs" forKey:ADJAdobeAdjustEventToken];
    [dataDict setValue:@"value1" forKey:[ADJAdobeAdjustEventPartnerParamPrefix stringByAppendingString:@"key1"]];
    [dataDict setValue:@"value2" forKey:[ADJAdobeAdjustEventPartnerParamPrefix stringByAppendingString:@"key2"]];
    [ACPCore trackAction:ADJAdobeAdjustActionTrackEvent data:dataDict];

    [dataDict removeAllObjects];

    // Set Push Token
    [dataDict setValue:@"your_app_push_token" forKey:ADJAdobeAdjustPushToken];
    [ACPCore trackAction:ADJAdobeAdjustActionSetPushToken data:dataDict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
