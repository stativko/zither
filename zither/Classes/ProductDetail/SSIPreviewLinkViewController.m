//
//  SSIPreviewLinkViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIPreviewLinkViewController.h"
#import "ReaderViewController.h"

@interface SSIPreviewLinkViewController () <UIWebViewDelegate, ReaderViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *savePage;
@property (strong, nonatomic) NSString *mimeType;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) BOOL shouldSaveOnDismiss;
@property (nonatomic, strong) ReaderViewController *readerViewController;
@property (nonatomic, strong) UILabel *doneSavingLabel;
@end

@implementation SSIPreviewLinkViewController

- (void)presentPDFReaderWithFilePath:(NSString*)filePath {
    if (filePath) {
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
        self.readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        self.readerViewController.delegate = self;
        self.readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:self.readerViewController animated:YES completion:nil];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.lblNavTitle setText:self.title];
    self.savePage.enabled = NO;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    
    self.activityView = [UIActivityIndicatorView createActivityIndicatorInView:self.view style:UIActivityIndicatorViewStyleGray offset:UIOffsetZero];
    if (self.fileToLoad) {
        if ([self cachedFileExists:self.fileToLoad.name]) {
            [self presentCachedFileName:self.fileToLoad.name];
            self.savePage.enabled = YES;
        } else {
            [self.fileToLoad getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self saveLocally:data withName:self.fileToLoad.name];
                [self presentCachedFileName:self.fileToLoad.name];
                self.savePage.enabled = YES;
            }];
        }
    } else if (self.savedUrl) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.savedUrl]];
    } else {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
    [self refreshSaveClearButton];
}

- (void)refreshSaveClearButton {
    if (self.fileToLoad || self.savedUrl) {
        [self.savePage setTitle:@"Clear" forState:UIControlStateNormal];
    } else {
        [self.savePage setTitle:@"Save" forState:UIControlStateNormal];
    }
}

- (NSString*)getDocumentCacheDir:(NSString*)dirName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dirPath = [documentsDirectory stringByAppendingPathComponent:dirName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        NSError *err = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:NO attributes:nil error:&err];
        if (err) {
            NSLog(@"Error: %@", err);
            return nil;
        }
    }
    return dirPath;
}

- (NSString*)localFileCachePathWithName:(NSString*)fileName {
    NSString *dirPath = nil;
    
    if ([fileName hasSuffix:@"pdf"]) {
        dirPath = [self getDocumentCacheDir:@"pdf"];
    } else if ([fileName hasSuffix:@"html"]) {
        dirPath = [self getDocumentCacheDir:@"html"];
    }
    NSString *pathName = [dirPath stringByAppendingPathComponent:fileName];

    return pathName;
}

- (BOOL)cachedFileExists:(NSString*)fileName {
    NSString *pathName = [self localFileCachePathWithName:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathName]) {
        return YES;
    }
    return NO;
}

- (BOOL)saveLocally:(NSData*)data withName:(NSString*)fileName {
    NSString *filePath = [self localFileCachePathWithName:fileName];
    return [data writeToFile:filePath atomically:YES];
}

- (void)presentCachedFileName:(NSString*)fileName {
    [self.activityView removeFromSuperview];

    NSString *filePath = [self localFileCachePathWithName:fileName];
    DDLogError(@"Showing Cached File: %@", filePath);
    if ([fileName hasSuffix:@"pdf"]) {
        [self presentPDFReaderWithFilePath:filePath];
    } else {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:nil];
    }
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.savePage.enabled = YES;
    [self.activityView removeFromSuperview];
}

- (IBAction)actionBack {
//    if (self.shouldSaveOnDismiss) {
//        [self.delegate previewController:self didSaveFile:self.fileToLoad withName:self.fileToLoad.name];
//    }
    [super actionBack];
}

- (IBAction)rightButtonAction:(id)sender {
    self.shouldSaveOnDismiss = NO;
    self.webView.hidden = NO;

    [self.doneSavingLabel removeFromSuperview];
    if ([self cachedFileExists:self.fileToLoad.name] || self.savedUrl) {
        [self.delegate previewControllerDidClearLink:self];
        NSString *localFile = [self localFileCachePathWithName:self.fileToLoad.name];
        if (localFile) {
            [[NSFileManager defaultManager] removeItemAtPath:localFile error:nil];
        }
        self.fileToLoad = nil;
        self.savedUrl = nil;
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    } else {
        if ([self.fileToLoad.name hasSuffix:@"pdf"]) {
            [self.delegate previewController:self didSaveFile:self.fileToLoad withURL:[NSURL URLWithString:self.fileToLoad.url]];
        } else {
            NSData *htmlFile = [NSData dataWithContentsOfURL:self.webView.request.URL];
            NSString *name = [NSString stringWithFormat:@"%@-%@.html", self.productId, self.userInfo[@"type"]];
            self.fileToLoad = [PFFile fileWithName:name data:htmlFile];
            [self.delegate previewController:self didSaveFile:self.fileToLoad withURL:self.webView.request.URL];
        }
//        else {
//            self.savedUrl = self.webView.request.URL;
//            [self.delegate previewController:self didSaveLink:self.webView.request.URL];
//        }
    }
    [self refreshSaveClearButton];
}

#define PFFileMaxNumBytes (10485760)
- (void)loadPDFFromLink:(NSURL*)pdfLink {
    
    NSString *name = [NSString stringWithFormat:@"%@-%@.pdf", self.productId, self.userInfo[@"type"]];

    if (self.savedUrl && [self cachedFileExists:name]) {
        [self presentCachedFileName:name];
        return;
    }
    
    self.activityView = [UIActivityIndicatorView createActivityIndicatorInView:self.view style:UIActivityIndicatorViewStyleGray offset:UIOffsetZero];
    NSData *pdfFile = [NSData dataWithContentsOfURL:pdfLink];
    [self saveLocally:pdfFile withName:name];

    if (pdfFile.length >= PFFileMaxNumBytes) {
        self.savedUrl = pdfLink;
        [self.delegate previewController:self didSaveLink:pdfLink];

    } else {
        self.fileToLoad = [PFFile fileWithName:name data:pdfFile];
        [self.delegate previewController:self didSaveFile:self.fileToLoad withURL:pdfLink];
    }
    [self presentCachedFileName:name];
//    self.shouldSaveOnDismiss = YES;

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[request.URL absoluteString] hasSuffix:@".pdf"]) {
        [self loadPDFFromLink:request.URL];
        return NO;
    }
    return YES;
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        self.doneSavingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
        self.doneSavingLabel.center = self.view.center;
        self.doneSavingLabel.textAlignment = NSTextAlignmentCenter;
        self.doneSavingLabel.text = [NSString stringWithFormat:@"PDF saved for off-line reading, tap \"Clear\" to search again."];
        self.doneSavingLabel.textColor = [UIColor darkGrayColor];
        self.doneSavingLabel.numberOfLines = 0;
        self.webView.hidden = YES;
        [self.view addSubview:self.doneSavingLabel];
        [self refreshSaveClearButton];
    }];
}
@end
