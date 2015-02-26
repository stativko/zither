//
//  SSISignUpViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSISignUpViewController.h"
#import <Intercom/Intercom.h>

#import "SSIIPGateway.h"

@interface SSISignUpViewController ()

@end

@implementation SSISignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.tfEmail becomeFirstResponder];
}

- (BOOL)validateFields
{
    if (![SSIUtils validateText:self.tfEmail.text]) {

        [SSIUtils showErrorMessage:@"Email cannot be empty"];
        return NO;
    }

    if (self.tfPassword.text.length <= 0) {

        [SSIUtils showErrorMessage:@"Password cannot be empty"];
        return NO;
    }

    return YES;
}

- (void)addACLToUser:(PFUser*)newUser {
    PFACL *userACL = [PFACL ACLWithUser:newUser];
    [newUser setACL:userACL];
    [newUser saveInBackground];
}
- (void)actionCreateAccount
{
    self.tfEmail.text = [self.tfEmail.text lowercaseString];

    if ([self validateFields]) {
        [SVProgressHUD showWithStatus:@"Signing up..."];
        PFUser *newUser = [PFUser user];
        [newUser setEmail:self.tfEmail.text];
        [newUser setUsername:self.tfEmail.text];
        [newUser setPassword:self.tfPassword.text];
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:@"Error signing up"];
                NSString *parseMessage = [[error userInfo] objectForKey:@"error"];
                if (parseMessage) {
                    [[[UIAlertView alloc] initWithTitle:@"Error signing up" message:parseMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                }
            }
            else {

                // See note in LoginViewController.  Inside my wrapper, it's
                // slightly different here for some reason
                SSIIPGateway *ipgw = [SSIIPGateway instance];
                if (!ipgw.isIntercomSessionStarted) {
                    if ([ipgw canStartIntercomSession]) {
                        [ipgw startIntercomSessionwithCompletion:^{
                            [Intercom beginSessionForUserWithEmail:newUser.email completion:nil];
                        }];
                    }
                } else {
                    [Intercom beginSessionForUserWithEmail:newUser.email completion:nil];
                }
                [self addACLToUser:newUser];
                [SVProgressHUD showSuccessWithStatus:@"User registered successfully"];
                [self performSegueWithIdentifier:@"successLogin" sender:self];
            }
        }];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.tfEmail) {

        [self.tfPassword becomeFirstResponder];
    }
    else if (textField == self.tfPassword) {

        [textField resignFirstResponder];
        [self actionCreateAccount];
    }

    return YES;
}

@end
