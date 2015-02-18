//
//  SSIDatePicker.h
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

@protocol SSIDatePickerDelegate

- (void)picker:(NSInteger)tag didChooseDate:(NSDate *)date;

@end

@interface SSIDatePicker : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) id defaultValue;
@property (nonatomic, weak) id<SSIDatePickerDelegate> delegate;
@property (nonatomic) NSInteger tag;

@property (nonatomic, weak) IBOutlet UINavigationItem *titleNavigationItem;
@property (nonatomic, weak) IBOutlet UIDatePicker *datePicker;

+ (SSIDatePicker *)viewWithTitle:(NSString *)title
                   defaultValue:(id)value
                       delegate:(id<SSIDatePickerDelegate>)delegate
                            tag:(NSInteger)tag;

- (void)show;
- (void)dismiss;

- (IBAction)actionCancel;
- (IBAction)actionDone;

@end
