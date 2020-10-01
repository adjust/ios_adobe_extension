//
//  ADJViewController.m
//  AdjustAdobeExtension
//
//  Created by rabc on 09/04/2020.
//  Copyright (c) 2020 rabc. All rights reserved.
//

#import "ADJViewController.h"
#import "ACPCore.h"

@interface ADJViewController ()

@end

@implementation ADJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [ACPCore trackAction:@"TestAction" data:@{@"a": @"b", @"adj.eventToken": @"123abc"}];
    [ACPCore trackState:@"TestState" data:@{@"a": @"b"}];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
