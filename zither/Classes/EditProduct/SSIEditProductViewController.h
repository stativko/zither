//
//  SSIEditProductViewController.h
//  WarrantyManager
//
//  Created by MacOs on 6/16/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIBaseViewController.h"

@interface SSIEditProductCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *productImageView;
@property (nonatomic, weak) IBOutlet UITextView *noteTextView;
@property (nonatomic, weak) IBOutlet UIButton *btnChooseImage;

@end

@interface SSIEditProductViewController : SSIBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PFObject *product;
@property (nonatomic, strong) PFObject *copiedProduct;
@property (nonatomic) BOOL shouldAddProduct;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)actionSaveProduct;

@end
