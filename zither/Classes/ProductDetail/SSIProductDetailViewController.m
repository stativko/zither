//
//  SSIProductDetailViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/17/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIProductDetailViewController.h"
#import "SSIEditProductViewController.h"
#import "SSIPreviewImageViewController.h"
#import "SSIPreviewLinkViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface SSIProductDetailViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SSIPreviewDelegate>

@property (nonatomic, strong) UITableViewCell *descriptionCell;

@end

@implementation SSIProductDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self applyProductToFields];
//    [self.product fetchIfNeededInBackground];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editProduct"]) {

        SSIEditProductViewController *editController = segue.destinationViewController;
        editController.product = self.product;
        editController.shouldAddProduct = NO;
    }
}

- (void)applyProductToFields
{
    [self.lblProductName setText:self.product[@"productName"]];

    PFFile *productImage = self.product[@"productImage"];
    NSString *productImageUrl = self.product[@"productImageUrl"];

    UIImage *placeholderImage = [UIImage imageNamed:@"product_placeholder"];
    [self.productImageView setImage:placeholderImage];

    if (productImage.url) {
        [productImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                self.productImageView.image = image;
            }
        }];
    }
    else if (productImageUrl) {

        [self.productImageView setImageWithURL:[NSURL URLWithString:productImageUrl] placeholderImage:placeholderImage];
    }

//    NSDate *expireDate = [SSIUtils expireDateFromProduct:self.product];
//    NSString *strExpirationDate = [SSIUtils stringFromDate:expireDate type:DATETYPE_PRODUCTDETAIL_EXPIRATION];
//    [self.lblExpires setText:[NSString stringWithFormat:@"Expires: %@", strExpirationDate]];
//    NSString *strWarrantyLength = [SSIUtils warrantyStringFromProduct:self.product];
//    [self.lblWarrantyLength setText:[NSString stringWithFormat:@"%@ warranty", strWarrantyLength]];
    long remainingWarrantyDays = [SSIUtils remainingWarrantyDaysFromProduct:self.product];
    [self.lblWarrantyLength setTextColor:(remainingWarrantyDays < 42) ? [UIColor colorWithRed:250.0 / 255.0 green:54.0 / 255.0 blue:100.0 / 255.0 alpha:1] : [UIColor blackColor]];
    [self.lblWarrantyLength setText:[SSIUtils remainingWarrantyStringFromProduct:self.product]];

    NSString *strPurchasedOn = [SSIUtils stringFromDate:self.product[@"purchasedOn"] type:DATETYPE_PRODUCTDETAIL_PURCHASEDON];
    NSString *strPurchasedFrom = self.product[@"purchasedFrom"];
    strPurchasedFrom = (strPurchasedFrom.length > 0) ? [NSString stringWithFormat:@"From %@", strPurchasedFrom] : @"";
    [self.lblPurchasedOn setText:[NSString stringWithFormat:@"Purchased On %@", strPurchasedOn]];
    [self.lblPurchasedFrom setText:strPurchasedFrom];

    self.descriptionCell = [self.tableView dequeueReusableCellWithIdentifier:@"descriptionCell"];

    [self.lblDescription setText:self.product[@"note"]];

    CGRect titleFrame = [self.lblProductName.text boundingRectWithSize:CGSizeMake(self.lblProductName.frame.size.width, 5000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.lblProductName.font} context:NULL];
    CGFloat height = 414.0 - 17.0f + titleFrame.size.height;
    self.tableView.tableHeaderView.frame = CGRectMake(0, 0, 320, height);
}

- (UILabel *)lblDescription
{
    return (UILabel *)[self.descriptionCell viewWithTag:1000];
}

- (void)dumpApiResponse
{
    [[[UIAlertView alloc] initWithTitle:@"Api Response" message:self.product[@"api_response"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)actionProductReceipt
{
    /*
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:@"Choose existing"];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {

        [actionSheet addButtonWithTitle:@"Take photo"];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;
    [actionSheet showInView:self.view];
    */
}

#pragma mark -
#pragma mark UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {  // note cell

        NSString *description = self.product[@"note"];
//        CGSize size = [description sizeWithFont:[UIFont fontWithName:@"Avenir-Roman" size:14.0f] constrainedToSize:CGSizeMake(280.0, 5000.0)];
        CGRect boundingRect = [description boundingRectWithSize:CGSizeMake(280.0, 5000.0) options:0 attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Avenir-Roman" size:14.0f]} context:NULL];

        return boundingRect.size.height + 26.0;
    }
    else if (indexPath.row == 1) {   // receipt

        PFFile *productReceipt = self.product[@"productReceipt"];
        if (productReceipt) {

            return 44.0;
        }
        else {

            return 0.0;
        }
    } else if (indexPath.row == 2) {   // serial
        
        PFFile *productSerial = self.product[@"productSerialNumber"];
        
        if (productSerial) {
            
            return 44.0;
        }
        else {
            
            return 0.0;
        }
    }
//    else if (indexPath.row == 4) {  // customer service.
//
//        BOOL hasPurchased = ([self.product[@"purchasedFrom"] length] > 0);
//        return (hasPurchased == YES) ? 44.0 : 0;
//    }

    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > 0) {

        NSString *identifier = @"detailCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

        NSArray *titles = @[@"Receipt", @"Serial Number", @"Find Manual", @"Customer Service"];

        UILabel *lblTitle = (UILabel *)[cell viewWithTag:100];
        if (indexPath.row == 3 && ([self.product objectForKey:@"manual"] || [self.product objectForKey:@"manual_url"])) {
            [lblTitle setText:@"Manual"];
        } else {
            [lblTitle setText:titles[indexPath.row - 1]];
        }

        return cell;
    }

    return self.descriptionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // receipt
    if (indexPath.row == 1) {
        SSIPreviewImageViewController *previewImageController = [self.storyboard instantiateViewControllerWithIdentifier:@"previewImageScreen"];
        PFFile *productReceipt = self.product[@"productReceipt"];
        previewImageController.imageUrl =  productReceipt.url;
        previewImageController.title = @"Product Receipt";
        [self.navigationController pushViewController:previewImageController animated:YES];
    }
    if (indexPath.row == 2) {
        
        SSIPreviewImageViewController *previewImageController = [self.storyboard instantiateViewControllerWithIdentifier:@"previewImageScreen"];
        PFFile *productReceipt = self.product[@"productSerialNumber"];
        previewImageController.imageUrl = productReceipt.url;
        previewImageController.title = @"Serial Number";
        [self.navigationController pushViewController:previewImageController animated:YES];
    }
    // find manual
    else if (indexPath.row == 3) {

        SSIPreviewLinkViewController *previewLinkController = [self.storyboard instantiateViewControllerWithIdentifier:@"previewLinkScreen"];
        previewLinkController.url = [SSIUtils findManualLinkForProduct:self.product];

        previewLinkController.title = @"Manual";
        previewLinkController.productId = self.product.objectId;
        previewLinkController.delegate = self;
        previewLinkController.userInfo = @{@"type" : @"manual"};
        if ([self.product objectForKey:@"manual"]) {
            previewLinkController.fileToLoad =[self.product objectForKey:@"manual"];
        } else if ([self.product objectForKey:@"manual_url"]) {
            NSURL *url = [NSURL URLWithString:[self.product objectForKey:@"manual_url"]];
            previewLinkController.savedUrl = url;
        } else {
            previewLinkController.title = @"Find Manual";
        }
        [self.navigationController pushViewController:previewLinkController animated:YES];
    }
    // customer svc
    else if (indexPath.row == 4) {

        SSIPreviewLinkViewController *previewLinkController = [self.storyboard instantiateViewControllerWithIdentifier:@"previewLinkScreen"];
        previewLinkController.url = [SSIUtils customerServiceLinkForProduct:self.product];
        previewLinkController.title = @"Customer Service";
        previewLinkController.productId = self.product.objectId;
        previewLinkController.delegate = self;
        previewLinkController.userInfo = @{@"type" : @"customerService"};
        if ([self.product objectForKey:@"customerService"]) {
            previewLinkController.fileToLoad = [self.product objectForKey:@"customerService"];
        } else if ([self.product objectForKey:@"customerService_url"]) {
            NSURL *url = [NSURL URLWithString:[self.product objectForKey:@"customerService_url"]];
           previewLinkController.savedUrl = url;
        }
        [self.navigationController pushViewController:previewLinkController animated:YES];
    }
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

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

    [SVProgressHUD showWithStatus:@"Saving Product..."];

    image = [SSIUtils scaledImage:image toSize:CGSizeMake(thres, thres)];
    [self.productImageView setImage:image];

    PFFile *productReceipt = [PFFile fileWithData:UIImagePNGRepresentation(image)];
    [productReceipt saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (succeeded) {

            self.product[@"productReceipt"] = productReceipt;
            [self.product saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                if (succeeded) {

                    [SVProgressHUD dismiss];
                }
                else {

                    [SVProgressHUD showErrorWithStatus:@"Error Saving Product"];
                }
            }];
        }
        else {

            [SVProgressHUD showErrorWithStatus:@"Error Saving Product"];
        }
    }];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)previewController:(SSIPreviewLinkViewController*) preview didSaveFile:(PFFile*)file withURL:(NSURL *)webUrl{
    if (file) {
        NSString *previewType = preview.userInfo[@"type"];
        //    PFFile *parseFile = [PFFile fileWithName:name data:file];
        [self.product setObject:file forKey:previewType];
        [self.product saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                DDLogDebug(@"Error saving: %@",error);
            }
        }];
    }
}

- (void)previewControllerDidClearLink:(SSIPreviewLinkViewController*) preview {
    NSString *previewType = preview.userInfo[@"type"];
    NSString *urlCol = [previewType stringByAppendingString:@"_url"];

    [self.product removeObjectForKey:previewType];
    [self.product removeObjectForKey:urlCol];
    [self.product saveInBackground];
}
- (void)previewController:(SSIPreviewLinkViewController *)preview didSaveLink:(NSURL *)link {
    NSString *previewType = preview.userInfo[@"type"];
    NSString *colName = [previewType stringByAppendingString:@"_url"];
    [self.product setObject:[link absoluteString] forKey:colName];
    [self.product saveInBackground];
}

@end
