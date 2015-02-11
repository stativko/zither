//
//  SSIPreviewImageViewController.h
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIBaseViewController.h"

@interface SSIPreviewImageViewController : SSIBaseViewController

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) NSString *imageUrl;

@end
