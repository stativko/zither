//
//  SSIUtils.h
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIWarrantyPicker.h"
#import "SSIDatePicker.h"

//#define TESTMODE

#pragma mark - KEYS
extern NSString *const SSI_PARSE_API;

enum {

    DATETYPE_EDITPRODUCT,
    DATETYPE_PRODUCTDETAIL_EXPIRATION,
    DATETYPE_PRODUCTDETAIL_PURCHASEDON
};

@interface SSIUtils : NSObject

+ (BOOL)shouldShowIntro;
+ (void)didShowIntro;

+ (BOOL)validateText:(NSString *)text;
+ (void)showErrorMessage:(NSString *)message;

+ (UIImage *)scaledImage:(UIImage *)image toSize:(CGSize)size;

+ (NSString *)stringFromDate:(NSDate *)date type:(int)type;
+ (NSDate *)dateFromString:(NSString *)string type:(int)type;

+ (NSString *)warrantyStringFromProduct:(id)product;
+ (NSString *)remainingWarrantyStringFromProduct:(id)product;
+ (long)remainingWarrantyDaysFromProduct:(id)product;

+ (NSDate *)expireDateFromProduct:(id)product;

+ (NSURL *)findManualLinkForProduct:(id)product;
+ (NSURL *)customerServiceLinkForProduct:(id)product;

+ (void)showWarrantyPickerWithTitle:(NSString *)title
                        defaultYear:(int)year
                       defaultMonth:(int)month
                         defaultDay:(int)day
                           delegate:(id<SSIWarrantyPickerDelegate>)delegate;

+ (void)showDatePickerWithTitle:(NSString *)title
                   defaultValue:(id)value
                       delegate:(id<SSIDatePickerDelegate>)delegate
                            tag:(int)tag;

+ (UIImage *)newEmptyImageForSize:(CGSize)size;

@end
