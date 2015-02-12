//
//  SSIMyStuffViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/15/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIMyStuffViewController.h"
#import "SSIProductCell.h"
#import "SSIProductDetailViewController.h"
#import "SSINotificationManager.h"
#import "SSIAppDelegate.h"
#import "SSIScanViewController.h"
#import "SSISearchViewController.h"
#import "SSIEditProductViewController.h"

@interface SSIMyStuffViewController () <SSIScanViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, strong) NSMutableArray *filteredProducts;

@property (nonatomic, strong) NSString *scannedCode;
@property (nonatomic, strong) NSArray *searchResults;

@property (nonatomic, strong) PFObject *productToEdit;

- (void)filterProducts:(NSString *)searchString;

@end

@implementation SSIMyStuffViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [[SSIAppDelegate sharedDelegate] setMystuffViewController:self];

    // this is for clear notifications
    self.products = nil;

    [self adjustSearchBar];
    
}


- (void)adjustSearchBar
{
    [self.searchBar setSearchFieldBackgroundImage:[SSIUtils newEmptyImageForSize:CGSizeMake(320, 44)] forState:UIControlStateNormal];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:@"Avenir-Roman" size:15]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadProducts];
}

- (void)actionAddProduct
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Product" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Scan Barcode", @"Enter Manually", nil];

    [actionSheet showInView:[self.navigationController view]];
}

- (void)navigateToProductDetail:(NSString *)productId
{
    while ([self.navigationController presentedViewController]) {

        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }

    [self.navigationController popToViewController:self animated:NO];

    for (PFObject *product in self.products) {

        if ([product.objectId isEqualToString:productId]) {

            SSIProductDetailViewController *detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"productDetailScreen"];
            detailController.product = product;
            [self.navigationController pushViewController:detailController animated:YES];
            break;
        }
    }

    [SSIAppDelegate sharedDelegate].expiringProductId = nil;
}

- (void)loadProducts
{
    [self.lblNoItems setHidden:YES];
    [self.lblNoSearchResults setHidden:YES];
    [self.searchBar setUserInteractionEnabled:NO];

//    [SVProgressHUD showWithStatus:@"Loading Products..."];
    PFQuery *query = [PFQuery queryWithClassName:@"Product"];
    [query whereKey:@"owner" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (error == nil) {

            [SVProgressHUD dismiss];
            self.products = [NSMutableArray arrayWithArray:objects];
            [self.products sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {

                if ([SSIUtils remainingWarrantyDaysFromProduct:obj1] < [SSIUtils remainingWarrantyDaysFromProduct:obj2]) {

                    return NSOrderedAscending;
                }
                else {

                    return NSOrderedDescending;
                }
            }];

            [self filterProducts:self.searchBar.text];

            if ([SSIAppDelegate sharedDelegate].expiringProductId) {

                [self navigateToProductDetail:[SSIAppDelegate sharedDelegate].expiringProductId];
            }
            [self.lblNoItems setHidden:([self.products count] > 0)];
            [self.searchBar setUserInteractionEnabled:([self.products count] > 0)];
        }
        else {

//            [SVProgressHUD showErrorWithStatus:@"Error in loading products..."];
        }
    }];
}

- (void)setProducts:(NSMutableArray *)products
{
    _products = products;

    [[SSINotificationManager sharedManager] setProducts:products];
    [[SSINotificationManager sharedManager] registerLocalNotifications];
}

- (void)filterProducts:(NSString *)searchString
{
    [self.lblNoSearchResults setHidden:YES];

    [self.filteredProducts removeAllObjects];
    self.filteredProducts = [NSMutableArray array];

    if (searchString.length <= 0) {

        [self.filteredProducts addObjectsFromArray:self.products];
    }
    else {

        for (PFObject *product in self.products) {

            NSString *name = product[@"productName"];
            if ([[name lowercaseString] rangeOfString:[searchString lowercaseString]].length > 0) {

                [self.filteredProducts addObject:product];
            }
        }

        [self.lblNoSearchResults setHidden:([self.filteredProducts count] > 0)];
    }

    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"productDetail"]) {

        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        SSIProductDetailViewController *detailController = (SSIProductDetailViewController *)segue.destinationViewController;
        detailController.product = self.filteredProducts[indexPath.row];
    }
    else if ([segue.identifier isEqualToString:@"showScan"]) {

        SSIScanViewController *scanController = (SSIScanViewController *)segue.destinationViewController;
        scanController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"showSearch"]) {

        SSISearchViewController *searchController = segue.destinationViewController;

        if (self.searchResults) {

            searchController.searchResults = self.searchResults;
        }
        else {

            searchController.searchString = self.searchBar.text;
        }
    }
    else if ([segue.identifier isEqualToString:@"addProduct"]) {

        SSIEditProductViewController *editController = segue.destinationViewController;
        editController.product = self.productToEdit;
        editController.shouldAddProduct = YES;
    }
}

- (void)setScannedCode:(NSString *)scannedCode
{
    _scannedCode = scannedCode;

    if ([scannedCode length] > 0) {

        [self loadProductsWithCode:scannedCode];
    }
}

#pragma mark -
#pragma mark api calling methods
- (void)loadProductsWithCode:(NSString *)scannedCode
{
    [SVProgressHUD showWithStatus:@"Loading Product Details..."];
    [SSIApi getProductDetailFromUPC:scannedCode success:^(NSArray *products) {

        [SVProgressHUD dismiss];

        [self didFinishLoadingProducts:products];
    } failure:^(NSString *error) {

        [SVProgressHUD showErrorWithStatus:error];
    }];
}

- (void)didFinishLoadingProducts:(NSArray *)products
{
    self.searchResults = products;
    [self performSegueWithIdentifier:@"showSearch" sender:self];
}

#pragma mark -
#pragma mark UICollectionViewDataSource, UICollectionViewDelegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.filteredProducts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"productCell";
    SSIProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell setProduct:self.filteredProducts[indexPath.row]];

    return cell;
}

#pragma mark -
#pragma mark UISearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterProducts:searchText];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    float keyboardHeight = 216.0;
    float navbarHeight = 64.0;
    CGPoint pt = self.lblNoSearchResults.center;
    pt.y = navbarHeight + (self.view.frame.size.height - keyboardHeight - navbarHeight) / 2;
    [UIView animateWithDuration:0.25f animations:^{

        [self.lblNoSearchResults setCenter:pt];
    }];

    searchBar.showsCancelButton = YES;
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    CGPoint pt = self.lblNoSearchResults.center;
    float navbarHeight = 64.0;
    pt.y = navbarHeight + (self.view.frame.size.height - navbarHeight) / 2;
    [UIView animateWithDuration:0.25f animations:^{

        [self.lblNoSearchResults setCenter:pt];
    }];

    searchBar.showsCancelButton = NO;
//    [self.navigationController setNavigationBarHidden:NO animated:YES];

    return YES;
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) { // Scan barcode

        [self performSegueWithIdentifier:@"showScan" sender:self];
    }
    else if (buttonIndex == 1) {    // Enter manually

        self.productToEdit = [SSIApi objectFromProductDict:@{@"name": (self.searchBar.text == nil) ? @"" : self.searchBar.text}];
        [self performSegueWithIdentifier:@"addProduct" sender:self];
    }
}

#pragma mark -
#pragma mark SSIScanViewControllerDelegate methods
- (void)scanViewController:(UIViewController *)viewController didScanCode:(NSString *)barcode
{
    [viewController dismissViewControllerAnimated:YES completion:^{

        self.scannedCode = barcode;
    }];
}

- (void)scanViewControllerDidCancel:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
