//
//  SSIScanViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/15/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIScanViewController.h"

@interface SSIScanViewController ()

@end

@implementation SSIScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupZbarView];
}

- (void)dealloc
{
    [self.zbarView stop];
    [self.zbarView removeFromSuperview];
}

- (void)setupZbarView
{
    ZBarImageScanner *scanner = [[ZBarImageScanner alloc] init];
    [scanner setSymbology: ZBAR_UPCA
                   config: ZBAR_CFG_ENABLE
                       to: 0];

    ZBarReaderView *zbarView = [[ZBarReaderView alloc] initWithImageScanner:scanner];
    zbarView.frame = self.cameraView.bounds;
    zbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    zbarView.readerDelegate = self;
    [self.cameraView addSubview:zbarView];
    [zbarView start];

    self.zbarView = zbarView;
}

- (void)actionCenterBarcode
{
    //
}

- (void)actionCancel
{
    [self.delegate scanViewControllerDidCancel:self];
}

#pragma mark -
#pragma mark ZBarReaderViewDelegate methods
- (void)readerView:(ZBarReaderView *)readerView
    didReadSymbols:(ZBarSymbolSet *)symbols
         fromImage:(UIImage *)image
{
    ZBarSymbol *symbol = nil;
    for(symbol in symbols){

        break;
    }

    // scanned code
    NSString *scannedCode = symbol.data;

    [self.delegate scanViewController:self didScanCode:scannedCode];

    [self.zbarView stop];
}

@end
