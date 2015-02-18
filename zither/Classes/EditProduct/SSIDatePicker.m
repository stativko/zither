//
//  SSIDatePicker.m
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIDatePicker.h"

@implementation SSIDatePicker

+ (SSIDatePicker *)viewWithTitle:(NSString *)title
                   defaultValue:(id)value
                       delegate:(id<SSIDatePickerDelegate>)delegate
                            tag:(NSInteger)tag
{
    SSIDatePicker *pickerView = (SSIDatePicker *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] objectAtIndex:0];
    pickerView.title = title;
    pickerView.defaultValue = value;
    pickerView.delegate = delegate;
    pickerView.tag = tag;

    return pickerView;
}

- (void)show
{
    [self.titleNavigationItem setTitle:self.title];
    if (self.defaultValue) {

        [self.datePicker setDate:self.defaultValue];
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
    [self.delegate picker:self.tag didChooseDate:self.datePicker.date];
    [self dismiss];
}

@end
