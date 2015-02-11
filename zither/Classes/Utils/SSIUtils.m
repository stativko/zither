//
//  SSIUtils.m
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIUtils.h"

#define keyShouldSkipIntro @"keyShouldSkipIntro"

@implementation SSIUtils

+ (BOOL)shouldShowIntro
{
    return ![[NSUserDefaults standardUserDefaults] boolForKey:keyShouldSkipIntro];
}

+ (void)didShowIntro
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:keyShouldSkipIntro];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)validateText:(NSString *)text
{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return (text.length > 0);
}

+ (void)showErrorMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    NSLog(@"%@", message);
}

+ (UIImage *)scaledImage:(UIImage *)image toSize:(CGSize)size
{
    CGFloat scale = MIN(image.size.width / size.width, image.size.height / size.height);
    CGRect rect;
    rect.size.width = image.size.width / scale;
    rect.size.height = image.size.height / scale;
    rect.origin.x = (size.width - rect.size.width) / 2;
    rect.origin.y = (size.height - rect.size.height) / 2;

    UIGraphicsBeginImageContext(size);
    [image drawInRect:rect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

+ (NSString *)stringFromDate:(NSDate *)date type:(int)type
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (type == DATETYPE_EDITPRODUCT) {

        [dateFormatter setDateFormat:@"d MMMM, yyyy"];
    }
    else if (type == DATETYPE_PRODUCTDETAIL_EXPIRATION) {

        [dateFormatter setDateFormat:@"d MMM, yyyy"];
    }
    else if (type == DATETYPE_PRODUCTDETAIL_PURCHASEDON) {

        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    }

    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string type:(int)type
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    if (type == DATETYPE_EDITPRODUCT) {

        [dateFormatter setDateFormat:@"d MMMM, yyyy"];
    }
    else if (type == DATETYPE_PRODUCTDETAIL_EXPIRATION) {

        [dateFormatter setDateFormat:@"d MMM, yyyy"];
    }
    else if (type == DATETYPE_PRODUCTDETAIL_PURCHASEDON) {

        [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    }

    return [dateFormatter dateFromString:string];
}

+ (NSString *)warrantyStringFromProduct:(PFObject *)product
{
    int year = [product[@"warrantyYear"] intValue];
    int month = [product[@"warrantyMonth"] intValue];
    int day = [product[@"warrantyDay"] intValue];

    NSArray *meter = @[@"year", @"month", @"day"];
    NSArray *meterShorten = @[@"yr", @"mon", @"d"];

    int n = (year > 0) + (month > 0) + (day > 0);

    if (n >= 2) {

        meter = meterShorten;
    }

    NSString *result = @"";
    result = (year > 0) ? [result stringByAppendingFormat:@"%d %@%@ ", year, meter[0], (year > 1) ? @"s" : @""] : result;
    result = (month > 0) ? [result stringByAppendingFormat:@"%d %@%@ ", month, meter[1], (month > 1) ? @"s" : @""] : result;
    result = (day > 0) ? [result stringByAppendingFormat:@"%d %@%@ ", day, meter[2], (day > 1) ? @"s" : @""] : result;

    result = (result.length > 0) ? result : @"No warranty";

    return result;
}

+ (NSString *)remainingWarrantyStringFromProduct:(id)product
{
    NSInteger year = [product[@"warrantyYear"] intValue];
    NSInteger month = [product[@"warrantyMonth"] intValue];
    NSInteger day = [product[@"warrantyDay"] intValue];

    if (year + month + day == 0) {

        return @"No warranty";
    }

    NSDate *date = product[@"purchasedOn"];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    dateComponents.year += year;
    dateComponents.month += month;
    dateComponents.day += day;

    NSDate *expirationDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];

    dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date] toDate:expirationDate options:0];

    year = dateComponents.year;
    month = dateComponents.month;
    day = dateComponents.day;

    int n = (year < 0) + (month < 0) + (day < 0);
    if (n > 0) {

        return @"Expired";
    }

    NSArray *meter = @[@"year", @"month", @"day"];
    NSArray *meterShorten = @[@"yr", @"mon", @"d"];

    n = (year > 0) + (month > 0) + (day > 0);

    if (n >= 2) {

        meter = meterShorten;
    }

    NSString *result = @"";
    result = (year > 0) ? [result stringByAppendingFormat:@"%lu %@%@ ", year, meter[0], (year > 1) ? @"s" : @""] : result;
    result = (month > 0) ? [result stringByAppendingFormat:@"%lu %@%@ ", month, meter[1], (month > 1) ? @"s" : @""] : result;
    result = (day > 0) ? [result stringByAppendingFormat:@"%lu %@%@ ", day, meter[2], (day > 1) ? @"s" : @""] : result;

    result = (result.length > 0) ? result : @"Expire today";

    return result;
}

+ (long)remainingWarrantyDaysFromProduct:(id)product
{
    NSInteger year = [product[@"warrantyYear"] intValue];
    NSInteger month = [product[@"warrantyMonth"] intValue];
    NSInteger day = [product[@"warrantyDay"] intValue];

    if (year + month + day == 0) {

        return 365000;
    }

    NSDate *date = product[@"purchasedOn"];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    dateComponents.year += year;
    dateComponents.month += month;
    dateComponents.day += day;

    NSDate *expirationDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];

    dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date] toDate:expirationDate options:0];
    day = dateComponents.day;

    return day;
}

+ (NSDate *)expireDateFromProduct:(PFObject *)product
{
    NSDate *purchasedOn = product[@"purchasedOn"];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:purchasedOn];
    dateComponents.day += [product[@"warrantyDay"] intValue];
    dateComponents.month += [product[@"warrantyMonth"] intValue];
    dateComponents.year += [product[@"warrantyYear"] intValue];

    return [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
}

+ (NSString *)urlEncodedStringFromString:(NSString *)string
{
    NSString *escapedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                    (__bridge CFStringRef)string,
                                                                                                    NULL,
                                                                                                    CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                                                                                    kCFStringEncodingUTF8));

    return escapedString;
}

+ (NSURL *)findManualLinkForProduct:(PFObject *)product
{
//    NSString *query = [NSString stringWithFormat:@"%@+manual", product[@"productName"]];
    NSString *query = [NSString stringWithFormat:@"%@+manual filetype:pdf", product[@"productName"]];
    query = [self urlEncodedStringFromString:query];
    NSString *strUrl = [NSString stringWithFormat:@"http://www.google.com?q=%@&gws_rd=ssl#q=%@", query, query];
    NSLog(@"%@", strUrl);

    return [NSURL URLWithString:strUrl];
}

+ (NSURL *)customerServiceLinkForProduct:(PFObject *)product
{
//    NSString *query = [NSString stringWithFormat:@"%@+customer+service+phone+number", product[@"purchasedFrom"]];
    NSString *query = [NSString stringWithFormat:@"%@+customer+service+phone+number", product[@"productName"]];
    query = [self urlEncodedStringFromString:query];
    NSString *strUrl = [NSString stringWithFormat:@"http://www.google.com?q=%@&gws_rd=ssl#q=%@", query, query];

    return [NSURL URLWithString:strUrl];
}

+ (void)showWarrantyPickerWithTitle:(NSString *)title
                        defaultYear:(int)year
                       defaultMonth:(int)month
                         defaultDay:(int)day
                           delegate:(id<SSIWarrantyPickerDelegate>)delegate
{
    SSIWarrantyPicker *pickerView = [SSIWarrantyPicker viewWithTitle:title defaultYear:year defaultMonth:month defaultDay:day delegate:delegate];
    [pickerView show];
}

+ (void)showDatePickerWithTitle:(NSString *)title
                   defaultValue:(id)value
                       delegate:(id<SSIDatePickerDelegate>)delegate
                            tag:(int)tag
{
    SSIDatePicker *pickerView = [SSIDatePicker viewWithTitle:title defaultValue:value delegate:delegate tag:tag];
    [pickerView show];
}

+ (UIImage *)newEmptyImageForSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1);
    CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
