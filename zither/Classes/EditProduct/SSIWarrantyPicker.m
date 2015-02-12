//
//  SSIWarrantyPicker.m
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIWarrantyPicker.h"

#define YEAR_MAX 10
#define MONTH_MAX 11
#define DAY_MAX 30

#define PICKER_ROW_HEIGHT 30.0

@implementation SSIWarrantyPicker

+ (SSIWarrantyPicker *)viewWithTitle:(NSString *)title
                        defaultYear:(NSInteger)year
                       defaultMonth:(NSInteger)month
                         defaultDay:(NSInteger)day
                           delegate:(id<SSIWarrantyPickerDelegate>)delegate
{
    SSIWarrantyPicker *pickerView = (SSIWarrantyPicker *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] objectAtIndex:0];
    pickerView.title = title;
    pickerView.defaultYear = year;
    pickerView.defaultMonth = month;
    pickerView.defaultDay = day;
    pickerView.delegate = delegate;

    return pickerView;
}

- (void)show
{
    [self.titleNavigationItem setTitle:self.title];
    [self.pickerView reloadAllComponents];

    if (self.defaultYear > 0) {

        [self.pickerView selectRow:2 inComponent:1 animated:NO];
        [self.pickerView selectRow:self.defaultYear inComponent:0 animated:NO];
    }
    else if (self.defaultMonth > 0) {

        [self.pickerView selectRow:1 inComponent:1 animated:NO];
        [self.pickerView selectRow:self.defaultMonth inComponent:0 animated:NO];
    }
    else if (self.defaultDay > 0) {

        [self.pickerView selectRow:0 inComponent:1 animated:NO];
        [self.pickerView selectRow:self.defaultDay inComponent:0 animated:NO];
    }

    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self];

    CGRect rect = self.frame;
    rect.origin.y = window.frame.size.height;
    rect.size.height = window.frame.size.height;
    self.frame = rect;

    [UIView animateWithDuration:0.25f animations:^{

        self.frame = CGRectOffset(self.frame, 0, -self.frame.size.height);
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25f animations:^{

        self.frame = CGRectOffset(self.frame, 0, self.frame.size.height);
    } completion:^(BOOL finished) {

        [self removeFromSuperview];
    }];
}

- (void)actionCancel
{
    [self dismiss];
}

- (void)actionDone
{
    NSInteger year = 0, month = 0, day = 0;
    NSInteger value = [self.pickerView selectedRowInComponent:0];
    switch ([self.pickerView selectedRowInComponent:1]) {

        case 0:
            day = value;
            break;

        case 1:
            month = value;
            break;

        case 2:
            year = value;
            break;

        default:
            break;
    }

    [self.delegate pickerDidChooseWarranty:year
                                     month:month
                                       day:day];

    [self dismiss];
}

#pragma mark -
#pragma mark UIPickerViewDataSource, UIPickerViewDelegate methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
//    return 6;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {

        return 31;
    }
    else {

        return 3;
    }
/*
    if (component == 0) {

        return YEAR_MAX + 1;
    }
    else if (component == 2) {

        return MONTH_MAX + 1;
    }
    else if (component == 4) {

        return DAY_MAX + 1;
    }
*/
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {

        return [NSString stringWithFormat:@"%lu", (long)row];
    }
    else {

        NSArray *titles = @[@"Day", @"Month", @"Year"];
        return titles[row];
    }
}
/*
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSString *content = @"";
    if (component == 1) {

        content = @"Year";
    }
    else if (component == 3) {

        content = @"Month";
    }
    else if (component == 5) {

        content = @"Day";
    }
    else {

        content = [NSString stringWithFormat:@"%d", row];
    }

    float width = [self pickerView:pickerView widthForComponent:component];
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, PICKER_ROW_HEIGHT)];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, PICKER_ROW_HEIGHT)];
    [contentLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [contentLabel setTextAlignment:NSTextAlignmentCenter];
    [contentLabel setTextColor:[UIColor blackColor]];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    [contentLabel setText:content];
    [newView addSubview:contentLabel];

    return newView;
}
*/
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return PICKER_ROW_HEIGHT;
}
/*
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 1
        || component == 3
        || component == 5) {

        return 55.0;
    }

    return 40.0;
}
*/
@end
