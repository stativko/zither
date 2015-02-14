//
//  SSIPreviewLinkViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIPreviewLinkViewController.h"

@interface SSIPreviewLinkViewController ()

@end

@implementation SSIPreviewLinkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.lblNavTitle setText:self.title];

    self.webView.scalesPageToFit = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

@end
