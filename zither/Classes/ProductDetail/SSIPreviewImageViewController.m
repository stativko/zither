//
//  SSIPreviewImageViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIPreviewImageViewController.h"
#import "UIImageView+AFNetworking.h"

@interface SSIPreviewImageViewController () <UIScrollViewDelegate>

@end

@implementation SSIPreviewImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.lblNavTitle setText:self.title];

    UIImage *placeholderImage = [UIImage imageNamed:@"product_placeholder"];
    [self.imageView setImage:placeholderImage];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.imageUrl]];
    UIActivityIndicatorView *av = [UIActivityIndicatorView createActivityIndicatorInView:self.view style:UIActivityIndicatorViewStyleGray offset:UIOffsetZero];
    [self.imageView setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [av removeFromSuperview];
        [self.imageView setImage:image];
        [self updateImageViewFrame];
        [self.scrollView setMinimumZoomScale:1.0f];
        [self.scrollView setMaximumZoomScale:4.0f];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {

    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateImageViewFrame];
}

- (void)updateImageViewFrame
{
    CGRect newFrame;
    CGFloat scale = MIN(self.scrollView.frame.size.width / self.imageView.image.size.width, self.scrollView.frame.size.height / self.imageView.image.size.height);

    newFrame.size.width = scale * self.imageView.image.size.width;
    newFrame.size.height = scale * self.imageView.image.size.height;
    newFrame.origin.x = (self.scrollView.frame.size.width - newFrame.size.width) / 2;
    newFrame.origin.y = (self.scrollView.frame.size.height - newFrame.size.height) / 2;

    self.scrollView.contentInset = UIEdgeInsetsMake(newFrame.origin.y, newFrame.origin.x, newFrame.origin.y, newFrame.origin.x);

    [self.scrollView setContentSize:newFrame.size];

    self.imageView.frame = CGRectMake(0, 0, newFrame.size.width, newFrame.size.height);
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

@end
