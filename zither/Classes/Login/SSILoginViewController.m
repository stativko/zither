//
//  SSILoginViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSILoginViewController.h"
#import <Intercom/Intercom.h>

#import "SSIIPGateway.h"

@interface SSILoginViewController ()

@end

@implementation SSILoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

#ifdef TESTMODE
    [self.tfEmail setText:@"test@test.com"];
    [self.tfPassword setText:@"test"];
#endif

    [self loadLoginCredentials];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tfEmail becomeFirstResponder];
}

- (void)saveLoginCredentials
{
    [[NSUserDefaults standardUserDefaults] setObject:self.tfEmail.text forKey:@"email"];
    [[NSUserDefaults standardUserDefaults] setObject:self.tfPassword.text forKey:@"password"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadLoginCredentials
{
    [self.tfEmail setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"]];
    [self.tfPassword setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
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

- (void)actionLogin
{
    self.tfEmail.text = [self.tfEmail.text lowercaseString];
    if ([self validateFields]) {
        
        [SVProgressHUD showWithStatus:@"Logging in..."];
        [PFUser logInWithUsernameInBackground:self.tfEmail.text password:self.tfPassword.text block:^(PFUser *user, NSError *error) {

            if (error) {

                [SVProgressHUD showErrorWithStatus:@"Error logging in"];
                NSString *parseMessage = [[error userInfo] objectForKey:@"error"];
                if (parseMessage) {
                    [[[UIAlertView alloc] initWithTitle:@"Error logging in" message:parseMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
                }
            }
            else {

                [self saveLoginCredentials];
                [self _startIntercomSession:user.email forgotPassword:NO];

                [SVProgressHUD showSuccessWithStatus:@"Login Success"];
                [self performSegueWithIdentifier:@"successLogin" sender:self];
            }
        }];
    }
}

- (void)actionForgotPassword
{
    if ([SSIUtils validateText:self.tfEmail.text]) {
        [self _startIntercomSession:self.tfEmail.text forgotPassword:YES];
        [SVProgressHUD showWithStatus:@"Requesting to reset password"];
        [PFUser requestPasswordResetForEmailInBackground:self.tfEmail.text block:^(BOOL succeeded, NSError *error) {

            if (error) {

                NSString *errorString = [error.userInfo[@"error"] capitalizedString];
                if (errorString.length > 0) {

                    [SVProgressHUD showErrorWithStatus:errorString];
                }
                else {

                    [SVProgressHUD showErrorWithStatus:@"Error occurred"];
                }
            }
            else {
                [SVProgressHUD showSuccessWithStatus:@"Password reset request accepted. Please check your mail"];
            }
        }];
    }
}

- (void)_beginIntercomUserSession:(NSString *)email forgotPassword:(BOOL)forgotPassword
{
    [Intercom beginSessionForUserWithEmail:email completion:^(NSError *error) {
        if (error == nil) {
            if (forgotPassword == YES) {
                [Intercom logEventWithName:@"user_forgotpassword" optionalMetaData:@{@"email": self.tfEmail.text} completion:nil];
            } else {
                [Intercom logEventWithName:@"user_login" completion:nil];
            }
        }
    }];
}

- (void)_startIntercomSession:(NSString *)email forgotPassword:(BOOL)forgotPassword
{
    
    SSIIPGateway *ipgw = [SSIIPGateway instance];
    // If the intercom session hasn't started, start it, and
    // call our block when it's done.  If it is started, then
    // call it without delay;
    if (!ipgw.isIntercomSessionStarted) {
        if (ipgw.dataToHash == nil) {
            ipgw.dataToHash = email;
        }
        if ([ipgw canStartIntercomSession]) {
            [ipgw startIntercomSessionwithCompletion:^{
                [self _beginIntercomUserSession:email
                                 forgotPassword:(BOOL)forgotPassword];
            }];
        }
    } else {
        [self _beginIntercomUserSession:email
                         forgotPassword:(BOOL)forgotPassword];
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
        [self actionLogin];
    }

    return YES;
}

@end
