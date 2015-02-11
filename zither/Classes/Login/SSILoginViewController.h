//
//  SSILoginViewController.h
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIBaseViewController.h"

@interface SSILoginViewController : SSIBaseViewController <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *tfEmail;
@property (nonatomic, weak) IBOutlet UITextField *tfPassword;

- (IBAction)actionLogin;
- (IBAction)actionForgotPassword;

@end
