//
//  SSIWarrantyPicker.h
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

@protocol SSIWarrantyPickerDelegate

- (void)pickerDidChooseWarranty:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end

@interface SSIWarrantyPicker : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSInteger defaultYear;
@property (nonatomic) NSInteger defaultMonth;
@property (nonatomic) NSInteger defaultDay;
@property (nonatomic, weak) id<SSIWarrantyPickerDelegate> delegate;

@property (nonatomic, weak) IBOutlet UINavigationItem *titleNavigationItem;
@property (nonatomic, weak) IBOutlet UIPickerView *pickerView;

+ (SSIWarrantyPicker *)viewWithTitle:(NSString *)title
                    defaultYear:(NSInteger)year
                   defaultMonth:(NSInteger)month
                     defaultDay:(NSInteger)day
                       delegate:(id<SSIWarrantyPickerDelegate>)delegate;

- (void)show;
- (void)dismiss;

- (IBAction)actionCancel;
- (IBAction)actionDone;

@end
