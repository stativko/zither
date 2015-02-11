//
//  SSIBaseViewController.h
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SVProgressHUD.h"

@interface SSIBaseViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *lblNavTitle;

- (void)setupNavigationBar;
- (IBAction)actionBack;

@end
