//
//  SSIScanViewController.h
//  WarrantyManager
//
//  Created by MacOs on 6/15/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIBaseViewController.h"
#import <ZBarSDK/ZBarReaderView.h>

@protocol SSIScanViewControllerDelegate

- (void)scanViewController:(UIViewController *)viewController didScanCode:(NSString *)barcode;
- (void)scanViewControllerDidCancel:(UIViewController *)viewController;

@end

@interface SSIScanViewController : SSIBaseViewController <ZBarReaderViewDelegate>

@property (nonatomic, weak) id<SSIScanViewControllerDelegate> delegate;

@property (nonatomic, weak) ZBarReaderView *zbarView;

@property (nonatomic, weak) IBOutlet UIView *cameraView;

- (IBAction)actionCenterBarcode;
- (IBAction)actionCancel;

@end
