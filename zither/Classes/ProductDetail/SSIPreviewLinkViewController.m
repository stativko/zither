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

- (BOOL)isPDF:(NSString *)filePath
{
    BOOL state = NO;
    
    if (filePath != nil) // Must have a file path
    {
        const char *path = [filePath fileSystemRepresentation];
        
        int fd = open(path, O_RDONLY); // Open the file
        
        if (fd > 0) // We have a valid file descriptor
        {
            const char sig[1024]; // File signature buffer
            
            ssize_t len = read(fd, (void *)&sig, sizeof(sig));
            
            state = (strnstr(sig, "%PDF", len) != NULL);
            
            close(fd); // Close the file
        }
    }
    
    return state;
}

- (void)presentPDFReaderWithFilePath:(NSString*)filePath {
    if (filePath && [self isPDF:filePath]) {
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
        self.readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
        if (self.readerViewController) {
            self.readerViewController.delegate = self;
            self.readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            self.readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:self.readerViewController animated:YES completion:nil];
        }
    }
}
-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
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
            self.savePage.enabled = YES;
            [self presentCachedFileName:self.fileToLoad.name];
        } else {
            [SVProgressHUD showWithStatus:@"Downloading..."];
            [self.fileToLoad getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.savePage.enabled = YES;
                [SVProgressHUD dismiss];
                [self saveLocally:data withName:self.fileToLoad.name];
                [self presentCachedFileName:self.fileToLoad.name];
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
    if ((self.fileToLoad) || self.savedUrl) {
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
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathName isDirectory:&isDirectory]) {
        return YES;
    }
    return NO;
}

- (BOOL)saveLocally:(NSData*)data withName:(NSString*)fileName {
    NSString *filePath = [self localFileCachePathWithName:fileName];
    return [data writeToFile:filePath atomically:NO];
}

- (void)presentCachedFileName:(NSString*)fileName {
    self.savePage.enabled = YES;

    [self.activityView removeFromSuperview];

    NSString *filePath = [self localFileCachePathWithName:fileName];
    DDLogError(@"Showing Cached File: %@", filePath);
    if ([[fileName lowercaseString] hasSuffix:@"pdf"]) {
        [self presentPDFReaderWithFilePath:filePath];
    } else {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [self.webView loadData:data MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:@""]];
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
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.savePage.enabled = YES;

    DDLogDebug(@"Received Error %@",error);
    
//    if (error) {
//        [[[UIAlertView alloc] initWithTitle:@"Try again." message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
//    }
}
- (IBAction)rightButtonAction:(id)sender {
    self.shouldSaveOnDismiss = NO;
    self.webView.hidden = NO;

    [self.doneSavingLabel removeFromSuperview];
    if ([[sender titleLabel].text isEqualToString:@"Clear"]) {
        [self.delegate previewControllerDidClearLink:self];
        NSString *localFile = [self localFileCachePathWithName:self.fileToLoad.name];
        if (localFile) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:localFile error:&error];
            if (error) {
                DDLogDebug(@"Received Error Removing file %@",error);
            }
        }
        self.fileToLoad = nil;
        self.savedUrl = nil;
        self.activityView = [UIActivityIndicatorView createActivityIndicatorInView:self.view style:UIActivityIndicatorViewStyleGray offset:UIOffsetZero];
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    } else {
        if ([[self.fileToLoad.name lowercaseString] hasSuffix:@"pdf"]) {
            [self.delegate previewController:self didSaveFile:self.fileToLoad withURL:[NSURL URLWithString:self.fileToLoad.url]];
        } else {
            self.savedUrl = self.webView.request.URL;
            [self.delegate previewController:self didSaveLink:self.webView.request.URL];
        }
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
    self.savePage.enabled = NO;
    [SVProgressHUD showWithStatus:@"Downloading..."];
        [[[NSURLSession sharedSession] downloadTaskWithURL:pdfLink completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            NSData *pdfFile = [NSData dataWithContentsOfURL:location];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];

                NSUInteger statusCode = 200;
                if ([response respondsToSelector:@selector(statusCode)]) {
                    statusCode = [(NSHTTPURLResponse*)response statusCode];
                }
                self.savePage.enabled = YES;
                if (pdfFile && statusCode != 404) {
                    if ([self saveLocally:pdfFile withName:name] && self.isViewLoaded) {
                        if (pdfFile.length >= PFFileMaxNumBytes) {
                            self.savedUrl = pdfLink;
                            [self.delegate previewController:self didSaveLink:pdfLink];
                        } else {
                            self.fileToLoad = [PFFile fileWithName:name data:pdfFile];
                            [self.delegate previewController:self didSaveFile:self.fileToLoad withURL:pdfLink];
                        }
                        if ([self cachedFileExists:name]) {
                            [self presentCachedFileName:name];
                        }
                    }
                } else {
                    if (error) {
                        DDLogDebug(@"Received Error %@",error);
                    } else if (statusCode == 404) {
                        [[[UIAlertView alloc] initWithTitle:@"Received 404" message:@"This file is not found on the link provided" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    }
                    [self.activityView removeFromSuperview];
                }
            });
        }] resume];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    self.webView.hidden = NO;

    if ([[[request.URL absoluteString] lowercaseString] hasSuffix:@".pdf"]) {
        [self loadPDFFromLink:request.URL];
        return NO;
    }
    return YES;
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        self.doneSavingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 100)];
        self.doneSavingLabel.center = self.view.center;
        self.doneSavingLabel.textAlignment = NSTextAlignmentLeft;
        self.doneSavingLabel.text = [NSString stringWithFormat:@"PDF saved for off-line reading.\n\nTap \"Clear\" to search again."];
        self.doneSavingLabel.textColor = [UIColor darkGrayColor];
        self.doneSavingLabel.numberOfLines = 0;
        self.webView.hidden = YES;
        [self.view addSubview:self.doneSavingLabel];
        [self refreshSaveClearButton];
    }];
}
@end
