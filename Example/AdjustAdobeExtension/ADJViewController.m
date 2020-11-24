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

    [ACPCore trackAction:@"TestAction" data:@{@"a": @"b", ADJAdobeAdjustEventToken: @"g3mfiw"}];
    [ACPCore trackState:@"TestState" data:@{@"a": @"b"}];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
