//
//  SSIAddProductViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/15/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIAddProductViewController.h"
#import "SSIScanViewController.h"
#import "SSISearchViewController.h"

@interface SSIAddProductViewController () <SSIScanViewControllerDelegate>

@property (nonatomic, strong) NSString *scannedCode;
@property (nonatomic, strong) SSIProductSearchResults *searchResults;

@end

@implementation SSIAddProductViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showScan"]) {

        SSIScanViewController *scanController = (SSIScanViewController *)segue.destinationViewController;
        scanController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"showSearch"]) {

        UINavigationController *navController = segue.destinationViewController;
        SSISearchViewController *searchController = (SSISearchViewController *)navController.topViewController;

        if (self.searchResults) {

            searchController.searchResults = self.searchResults;
        }
        else {

            searchController.searchString = self.searchBar.text;
        }
    }
}

- (void)setScannedCode:(NSString *)scannedCode
{
    if ([_scannedCode isEqualToString:scannedCode]) {

        return;
    }

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
    [SSIApi getProductDetailFromUPC:scannedCode success:^(SSIProductSearchResults *result) {

        [SVProgressHUD dismiss];

        [self didFinishLoadingProducts:result];
    } failure:^(NSString *error) {

        [SVProgressHUD showErrorWithStatus:error];
    }];
}

- (void)didFinishLoadingProducts:(SSIProductSearchResults *)products
{
    self.searchResults = products;
    [self performSegueWithIdentifier:@"showSearch" sender:self];
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

#pragma mark -
#pragma mark UISearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

    self.searchResults = nil;
    [self performSegueWithIdentifier:@"showSearch" sender:self];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
