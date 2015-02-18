//
//  SSIEditProductViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/16/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIEditProductViewController.h"
#import <BZGFormViewController/BZGTextFieldCell.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImageView+AFNetworking.h"
#import "SSINotificationManager.h"

#import <Intercom/Intercom.h>
#import "SSIMyStuffViewController.h"

enum {

    ALERT_DELETE,
};

@implementation SSIEditProductCell
-(void)prepareForReuse {
    [super prepareForReuse];
    self.productImageView.image = nil;
}
@end

#define HEADER_HEIGHT 44.0
#define SPECIFIC_CELL_HEIGHT 160.0

int _numberOfSections = 4;
int _numberOfRows[] = {4, 2, 1, 1, 1};

enum {

    CHOOSE_PRODUCT_RECEIPT,
    CHOOSE_PRODUCT_IMAGE,
    CHOOSE_PRODUCT_SERIALNUMBER
};

@interface SSIEditProductViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, SSIWarrantyPickerDelegate, SSIDatePickerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) BZGTextFieldCell *productNameCell;
@property (nonatomic, strong) BZGTextFieldCell *purchasedOnCell;
@property (nonatomic, strong) BZGTextFieldCell *warrantyCell;
@property (nonatomic, strong) BZGTextFieldCell *purchasedFromCell;
//@property (nonatomic, strong) BZGTextFieldCell *productURLCell;
@property (nonatomic, strong) SSIEditProductCell *productReceiptCell;
@property (nonatomic, strong) SSIEditProductCell *productImageCell;
@property (nonatomic, strong) SSIEditProductCell *productSerialNumberCell;
@property (nonatomic, strong) SSIEditProductCell *noteCell;

@property (nonatomic, strong) UIImage *productReceipt_New;
@property (nonatomic, strong) UIImage *productImage_New;
@property (nonatomic, strong) UIImage *productSerialNumber_New;

@property (nonatomic) int imagePickerIndex;

@property (nonatomic) BOOL isWarrantyEdit;

- (void)configureCells;

@end

@implementation SSIEditProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self.lblNavTitle setText:(self.shouldAddProduct == YES) ? @"Add Product" : @"Edit Product"];

    [self configureCells];
    [self.tableView reloadData];
    [self applyProductToCells];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)configureCells
{
    UIFont *cellLabelFont = [UIFont fontWithName:@"Avenir-Heavy" size:14.0f];
    UIFont *cellTextFieldFont = [UIFont fontWithName:@"Avenir-Roman" size:14.0f];

    // product name
    self.productNameCell = [BZGTextFieldCell new];
    self.productNameCell.label.font = cellLabelFont;
    self.productNameCell.label.text = @"Product Name";
    self.productNameCell.textField.font = cellTextFieldFont;
    self.productNameCell.textField.placeholder = @"Product Name";
    self.productNameCell.textField.keyboardType = UIKeyboardTypeASCIICapable;
    self.productNameCell.label.font = cellLabelFont;
    self.productNameCell.shouldChangeTextBlock = ^BOOL(BZGTextFieldCell *cell, NSString *newText) {
        return YES;
    };

    // purchased on
    self.purchasedOnCell = [BZGTextFieldCell new];
    self.purchasedOnCell.label.font = cellLabelFont;
    self.purchasedOnCell.label.text = @"Purchased On";
    self.purchasedOnCell.textField.font = cellTextFieldFont;
    self.purchasedOnCell.textField.placeholder = @"";
    self.purchasedOnCell.textField.delegate = self;
    self.purchasedOnCell.shouldChangeTextBlock = ^BOOL(BZGTextFieldCell *cell, NSString *newText) {
        return YES;
    };

    // warranty
    self.warrantyCell = [BZGTextFieldCell new];
    self.warrantyCell.label.font = cellLabelFont;
    self.warrantyCell.label.text = @"Warranty";
    self.warrantyCell.textField.font = cellTextFieldFont;
    self.warrantyCell.textField.placeholder = @"";
    self.warrantyCell.textField.delegate = self;
    self.warrantyCell.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.warrantyCell.shouldChangeTextBlock = ^BOOL(BZGTextFieldCell *cell, NSString *newText) {
        return YES;
    };

    // purchased from
    self.purchasedFromCell = [BZGTextFieldCell new];
    self.purchasedFromCell.label.font = [UIFont fontWithName:@"Avenir-Heavy" size:12.0f];
    self.purchasedFromCell.label.text = @"Purchased From";
    self.purchasedFromCell.textField.font = cellTextFieldFont;
    self.purchasedFromCell.textField.placeholder = @"Purchased From";
    self.purchasedFromCell.textField.keyboardType = UIKeyboardTypeASCIICapable;
    self.purchasedFromCell.shouldChangeTextBlock = ^BOOL(BZGTextFieldCell *cell, NSString *newText) {
        return YES;
    };

    self.productReceiptCell = [self.tableView dequeueReusableCellWithIdentifier:@"productReceiptCell"];
    self.productImageCell = [self.tableView dequeueReusableCellWithIdentifier:@"productImageCell"];
    self.productSerialNumberCell = [self.tableView dequeueReusableCellWithIdentifier:@"productSerialNumberCell"];
    self.noteCell = [self.tableView dequeueReusableCellWithIdentifier:@"noteCell"];

    [self.productReceiptCell.btnChooseImage addTarget:self action:@selector(actionChooseProductReceipt) forControlEvents:UIControlEventTouchUpInside];
    [self.productImageCell.btnChooseImage addTarget:self action:@selector(actionChooseProductImage) forControlEvents:UIControlEventTouchUpInside];
    [self.productSerialNumberCell.btnChooseImage addTarget:self action:@selector(actionChooseProductSerialNumber) forControlEvents:UIControlEventTouchUpInside];
}

- (void)applyProductToCells
{
    self.isWarrantyEdit = NO;
    self.productNameCell.textField.text = self.product[@"productName"];
    self.purchasedOnCell.textField.text = [SSIUtils stringFromDate:self.product[@"purchasedOn"] type:DATETYPE_EDITPRODUCT];
    self.warrantyCell.textField.text = [SSIUtils warrantyStringFromProduct:self.product];
    self.purchasedFromCell.textField.text = self.product[@"purchasedFrom"];
    [self.noteCell.noteTextView setText:self.product[@"note"]];

    PFFile *productReceipt = self.product[@"productReceipt"];
    PFFile *productImage = self.product[@"productImage"];
    PFFile *productSerialNumber = self.product[@"productSerialNumber"];
    NSString *productImageUrl = self.product[@"productImageUrl"];
    UIImage *placeholderImage = [UIImage imageNamed:@"product_placeholder"];


    if (productReceipt.url) {
        [self.productReceiptCell.productImageView setImage:placeholderImage];
        [productReceipt getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                self.productReceiptCell.productImageView.image = image;
            }
        }];
    }
    if (productImage.url) {
        [self.productImageCell.productImageView setImage:placeholderImage];

        [productImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                [self.productImageCell.productImageView setImage:image];
            }
        }];
    }
    else if (productImageUrl) {

        [self.productImageCell.productImageView setImageWithURL:[NSURL URLWithString:productImageUrl] placeholderImage:placeholderImage];
    }

    if (productSerialNumber.url) {
        [self.productSerialNumberCell.productImageView setImage:placeholderImage];

        [productSerialNumber getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                self.productSerialNumberCell.productImageView.image = image;
            }
        }];
    }
}

- (void)actionChooseProductReceipt
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:@"Choose existing"];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        [actionSheet addButtonWithTitle:@"Take photo"];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    [actionSheet showInView:self.view];

    self.imagePickerIndex = CHOOSE_PRODUCT_RECEIPT;
}

- (void)actionChooseProductImage
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:@"Choose existing"];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        [actionSheet addButtonWithTitle:@"Take photo"];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    [actionSheet showInView:self.view];

    self.imagePickerIndex = CHOOSE_PRODUCT_IMAGE;
}

- (void)actionChooseProductSerialNumber
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:@"Choose existing"];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        [actionSheet addButtonWithTitle:@"Take photo"];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    [actionSheet showInView:self.view];

    self.imagePickerIndex = CHOOSE_PRODUCT_SERIALNUMBER;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {

        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = buttonIndex == 0 ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(__bridge NSString *) kUTTypeImage];

        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    float thres = 512;
    CGSize size = image.size;
    if (size.width > size.height) {

        size.height = thres * size.height / size.width;
        size.width = thres;
    }
    else {

        size.width = thres * size.width / size.height;
        size.height = thres;
    }

    image = [SSIUtils scaledImage:image toSize:CGSizeMake(thres, thres)];
    if (self.imagePickerIndex == CHOOSE_PRODUCT_RECEIPT) {

        [self.productReceiptCell.productImageView cancelImageRequestOperation];
        self.productReceiptCell.productImageView.image = image;
        self.productReceipt_New = image;
    }
    else if (self.imagePickerIndex == CHOOSE_PRODUCT_IMAGE) {

        [self.productImageCell.productImageView cancelImageRequestOperation];
        self.productImageCell.productImageView.image = image;
        self.productImage_New = image;
    }
    else if (self.imagePickerIndex == CHOOSE_PRODUCT_SERIALNUMBER) {

        [self.productSerialNumberCell.productImageView cancelImageRequestOperation];
        self.productSerialNumberCell.productImageView.image = image;
        self.productSerialNumber_New = image;
    }

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSaveProduct
{
    [SVProgressHUD showWithStatus:@"Saving Product..."];

    NSString *productName = self.productNameCell.textField.text;
    NSDate *purchasedDate = [SSIUtils dateFromString:self.purchasedOnCell.textField.text type:DATETYPE_EDITPRODUCT];
    NSString *purchasedFrom = self.purchasedFromCell.textField.text;
//    NSString *productURL = self.productURLCell.textField.text;
    NSString *note = self.noteCell.noteTextView.text;

    productName = (productName == nil) ? @"" : productName;
    purchasedDate = (purchasedDate == nil) ? [NSDate date] : purchasedDate;
    purchasedFrom = (purchasedFrom == nil) ? @"" : purchasedFrom;
//    productURL = (productURL == nil) ? @"" : productURL;
    note = (note == nil) ? @"" : note;

    self.product[@"productName"] = productName;
    self.product[@"purchasedOn"] = purchasedDate;
    self.product[@"purchasedFrom"] = purchasedFrom;
//    self.product[@"productURL"] = productURL;
    self.product[@"note"] = [note stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    self.product[@"owner"] = [PFUser currentUser];

    // NOTE: This is also were we should verify that changes were made.

    PFBooleanResultBlock saveFinish = ^(BOOL succeeded, NSError *error) {
        if (self.copiedProduct && ![[self.copiedProduct objectForKey:@"owner"] isEqualToString:[PFUser currentUser].objectId]) {
            [self.copiedProduct incrementKey:@"numShares"];
            [self.copiedProduct saveInBackground]; // save the increment on the object
        }
        
        [SVProgressHUD dismiss];

        if (succeeded && error == nil) {

            [[SSINotificationManager sharedManager] registerLocalNotifications];
        }

        if (self.shouldAddProduct) {

            [Intercom logEventWithName:@"product_add" completion:nil];
        }
        else {
            NSDictionary *options;
            // It doesn't really look like this meta data is visible from
            // Intercom's web interface.  So, maybe this should be a
            // separate log event.
            if (self.isWarrantyEdit)
                options = @{@"edit_type":@"warranty_changed"};
            [Intercom logEventWithName:@"product_edit"
                      optionalMetaData:options
                            completion:nil];
        }

        for (UIViewController *viewController in [self.navigationController viewControllers]) {

            if ([NSStringFromClass([viewController class]) isEqualToString:@"SSIMyStuffViewController"]) {
                SSIMyStuffViewController *mystuff = (SSIMyStuffViewController*)viewController;//BAAAAD
                mystuff.forceRefresh = YES;
                [self.navigationController popToViewController:viewController animated:YES];
                
                break;
            }
        }
    };

    __block NSInteger imagesUploaded = 0;
    void (^imageUploadFinish)() = ^() {

        imagesUploaded ++;
        if (imagesUploaded == 3) {

            [self.product saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                saveFinish(succeeded, error);
            }];
        }
    };

    if (self.productReceipt_New) {
        PFFile *productReceipt = [PFFile fileWithName:@"receipt.jpg" data:UIImageJPEGRepresentation(self.productReceipt_New, .5)];
        [productReceipt saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            if (succeeded) {

                self.product[@"productReceipt"] = productReceipt;
            }

            imageUploadFinish();
        }];
    }
    else {

        imageUploadFinish();
    }

    if (self.productSerialNumber_New) {

        PFFile *productSerialNumber = [PFFile fileWithName:@"serial.jpg" data:UIImageJPEGRepresentation(self.productSerialNumber_New, .5)];
        [productSerialNumber saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {

                self.product[@"productSerialNumber"] = productSerialNumber;
            }
            imageUploadFinish();
        }];
    }
    else {

        imageUploadFinish();
    }

    if (self.productImage_New) {
        PFFile *productImage = [PFFile fileWithName:@"product.jpg" data:UIImageJPEGRepresentation(self.productImage_New, .8)];

//        PFFile *productImage = [PFFile fileWithData:UIImagePNGRepresentation(self.productImage_New)];
        [productImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            if (succeeded) {

                self.product[@"productImage"] = productImage;
            }

            imageUploadFinish();
        }];
    }
    else {

        imageUploadFinish();
    }
}

- (void)deleteProduct
{
    [SVProgressHUD showWithStatus:@"Deleting..."];
    [self.product deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (succeeded) {

            [SVProgressHUD dismiss];

            for (UIViewController *viewController in [self.navigationController viewControllers]) {

                if ([NSStringFromClass([viewController class]) isEqualToString:@"SSIMyStuffViewController"]) {

                    [self.navigationController popToViewController:viewController animated:YES];
                    break;
                }
            }
        }
        else {

            [SVProgressHUD showErrorWithStatus:@"Can't delete the product"];
        }
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _numberOfSections + !_shouldAddProduct;  // if user editing product, show delete option
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _numberOfRows[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return HEADER_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0) {

        if (indexPath.row == 0) {

            return self.productNameCell;
        }
        else if (indexPath.row == 1) {

            return self.productReceiptCell;
        }
        else if (indexPath.row == 2) {

            return self.purchasedOnCell;
        }
        else if (indexPath.row == 3) {

            return self.warrantyCell;
        }
    }
    else if (indexPath.section == 1) {

        if (indexPath.row == 0) {

            return self.productImageCell;
        }
        else if (indexPath.row == 1) {

            return self.purchasedFromCell;
        }
//        else if (indexPath.row == 2) {
//
//            return self.productURLCell;
//        }
    }
    else if (indexPath.section == 2) {

        return self.productSerialNumberCell;
    }
    else if (indexPath.section == 3) {

        return self.noteCell;
    }


    if (indexPath.section == 4) {
        NSString *identifier = @"deleteCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.contentView.backgroundColor = [UIColor whiteColor];
        [cell.textLabel setTextColor:[UIColor redColor]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        [cell.textLabel setText:@"Delete"];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0 && indexPath.row == 1)
        || (indexPath.section == 1 && indexPath.row == 0)
        || (indexPath.section == 2)
        || (indexPath.section == 3)) {

            return SPECIFIC_CELL_HEIGHT;
    }

    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 4) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Delete this product?" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:@"Cancel", nil];
        alertView.tag = ALERT_DELETE;
        [alertView show];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.purchasedOnCell.textField) {

        [self.view endEditing:YES];

        [SSIUtils showDatePickerWithTitle:@"Choose date" defaultValue:self.product[@"purchasedOn"] delegate:self tag:0];
        return NO;
    }
    else if (textField == self.warrantyCell.textField) {

        [self.view endEditing:YES];

        int year = [self.product[@"warrantyYear"] intValue];
        int month = [self.product[@"warrantyMonth"] intValue];
        int day = [self.product[@"warrantyDay"] intValue];
        [SSIUtils showWarrantyPickerWithTitle:@"Choose warranty" defaultYear:year defaultMonth:month defaultDay:day delegate:self];

        return NO;
    }

    return YES;
}

#pragma mark -
#pragma mark SSIWarrantyPickerDelegate methods

- (void)pickerDidChooseWarranty:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    self.product[@"warrantyYear"] = @(year);
    self.product[@"warrantyMonth"] = @(month);
    self.product[@"warrantyDay"] = @(day);
    self.warrantyCell.textField.text = [SSIUtils warrantyStringFromProduct:self.product];
    self.isWarrantyEdit = YES;

}

#pragma mark -
#pragma mark SSIDatePickerDelegate methods

- (void)picker:(NSInteger)tag didChooseDate:(NSDate *)date
{
    self.purchasedOnCell.textField.text = [SSIUtils stringFromDate:date type:DATETYPE_EDITPRODUCT];
    self.isWarrantyEdit = YES;
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_DELETE) {

        if (buttonIndex == alertView.cancelButtonIndex) {

            [self deleteProduct];
        }
    }
}

@end
