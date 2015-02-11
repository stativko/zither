//
//  SSIBaseViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIBaseViewController.h"

#define SCREEN_BGCOLOR [UIColor colorWithWhite:0.95 alpha:1]

@interface SSIBaseViewController ()

@end

@implementation SSIBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self setupNavigationBar];

    [self.view setBackgroundColor:SCREEN_BGCOLOR];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupNavigationBar
{
    //
}

- (void)actionBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
