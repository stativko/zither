//
//  SSIPreviewLinkViewController.h
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIBaseViewController.h"

@protocol SSIPreviewDelegate;

@interface SSIPreviewLinkViewController : SSIBaseViewController

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *savedUrl;
@property (nonatomic, weak) id<SSIPreviewDelegate> delegate;
@property (nonatomic, strong) PFFile *fileToLoad;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSString *productId;
@end

@protocol SSIPreviewDelegate <NSObject>

- (void)previewController:(SSIPreviewLinkViewController*) preview didSaveFile:(PFFile*)file withURL:(NSURL*)url;
- (void)previewControllerDidClearLink:(SSIPreviewLinkViewController*) preview;

@optional
- (void)previewController:(SSIPreviewLinkViewController*) preview didSaveLink:(NSURL*)link;


@end
