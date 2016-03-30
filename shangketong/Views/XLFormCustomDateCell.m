//
//  XLFormCustomDateCell.m
//  shangketong
//
//  Created by sungoin-zbs on 16/3/11.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "XLFormCustomDateCell.h"

NSString * const XLFormRowDescriptorTypeCustomDate = @"XLFormRowDescriptorTypeCustomDate";

@interface XLFormCustomDateCell ()

@property (nonatomic) UIDatePicker *datePicker;
@end

@implementation XLFormCustomDateCell {
    UIColor *_beforeChangeColor;
}

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormCustomDateCell class] forKey:XLFormRowDescriptorTypeCustomDate];
}

- (UIView *)inputView {
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDate] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeDateTime] || [self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeCountDownTimer]){
        if (self.rowDescriptor.value){
            [self.datePicker setDate:self.rowDescriptor.value animated:[self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeCountDownTimer]];
        }
        [self setModeToDatePicker:self.datePicker];
        return self.datePicker;
    }
    return [super inputView];
}

- (BOOL)canBecomeFirstResponder
{
    return !self.rowDescriptor.isDisabled;
}

-(BOOL)becomeFirstResponder
{
    if (self.isFirstResponder){
        return [super becomeFirstResponder];
    }
    _beforeChangeColor = self.detailTextLabel.textColor;
    BOOL result = [super becomeFirstResponder];
    if (result){
        if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeCustomDate])
        {
            NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
            NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:(selectedRowPath.row + 1) inSection:selectedRowPath.section];
            XLFormSectionDescriptor * formSection = [self.formViewController.form.formSections objectAtIndex:nextRowPath.section];
            XLFormRowDescriptor * datePickerRowDescriptor = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeDatePicker];
            XLFormDatePickerCell * datePickerCell = (XLFormDatePickerCell *)[datePickerRowDescriptor cellForFormController:self.formViewController];
            [self setModeToDatePicker:datePickerCell.datePicker];
            if (self.rowDescriptor.value){
                [datePickerCell.datePicker setDate:self.rowDescriptor.value animated:[self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeCountDownTimerInline]];
            }
            NSAssert([datePickerCell conformsToProtocol:@protocol(XLFormInlineRowDescriptorCell)], @"inline cell must conform to XLFormInlineRowDescriptorCell");
            UITableViewCell<XLFormInlineRowDescriptorCell> * inlineCell = (UITableViewCell<XLFormInlineRowDescriptorCell> *)datePickerCell;
            inlineCell.inlineRowDescriptor = self.rowDescriptor;
            
            [formSection addFormRow:datePickerRowDescriptor afterRow:self.rowDescriptor];
            [self.formViewController ensureRowIsVisible:datePickerRowDescriptor];
        }
    }
    return result;
}

-(BOOL)resignFirstResponder
{
    if ([self.rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeCustomDate])
    {
        NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
        NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
        XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
        BOOL result = [super resignFirstResponder];
        if ([nextFormRow.rowType isEqualToString:XLFormRowDescriptorTypeDatePicker]){
            [self.rowDescriptor.sectionDescriptor removeFormRow:nextFormRow];
        }
        return result;
    }
    return [super resignFirstResponder];
}

#pragma mark - XLFormDescriptorCell
- (void)configure {
    [super configure];
    
    self.formDatePickerMode = XLFormCustomDateDatePickerModeDate;
}

- (void)update {
    [super update];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.editingAccessoryType = UITableViewCellAccessoryNone;
    [self.textLabel setText:self.rowDescriptor.title];
    self.selectionStyle = self.rowDescriptor.isDisabled ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    self.textLabel.text = [NSString stringWithFormat:@"%@%@", self.rowDescriptor.title, self.rowDescriptor.required && self.rowDescriptor.sectionDescriptor.formDescriptor.addAsteriskToRequiredRowsTitle ? @"*" : @""];
    self.detailTextLabel.text = [self valueDisplayText];
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    if (!self.rowDescriptor.value) {
        self.rowDescriptor.value = [NSDate date];
    }
    [self.formViewController.tableView deselectRowAtIndexPath:[controller.form indexPathOfFormRow:self.rowDescriptor] animated:YES];
}

- (BOOL)formDescriptorCellCanBecomeFirstResponder {
    return [self canBecomeFirstResponder];
}

- (BOOL)formDescriptorCellBecomeFirstResponder {
    if ([self isFirstResponder]) {
        return [self resignFirstResponder];
    }
    return [self becomeFirstResponder];
}

- (void)highlight {
    [super highlight];
    self.detailTextLabel.textColor = self.tintColor;
}

- (void)unhighlight {
    [super unhighlight];
    self.detailTextLabel.textColor = _beforeChangeColor;
}

#pragma mark - helpers
- (NSString *)valueDisplayText {
    return self.rowDescriptor.value ? [self formattedDate:self.rowDescriptor.value] : self.rowDescriptor.noValueDisplayText;
}

- (NSString *)formattedDate:(NSDate *)date {
    if (self.rowDescriptor.valueTransformer){
        NSAssert([self.rowDescriptor.valueTransformer isSubclassOfClass:[NSValueTransformer class]], @"valueTransformer is not a subclass of NSValueTransformer");
        NSValueTransformer * valueTransformer = [self.rowDescriptor.valueTransformer new];
        NSString * tranformedValue = [valueTransformer transformedValue:self.rowDescriptor.value];
        if (tranformedValue){
            return tranformedValue;
        }
    }
    if (self.formDatePickerMode == XLFormCustomDateDatePickerModeDate){
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    }
    else if (self.formDatePickerMode == XLFormCustomDateDatePickerModeTime){
        return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    }

    return [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (void)setModeToDatePicker:(UIDatePicker *)datePicker {
    
    if (self.formDatePickerMode == XLFormCustomDateDatePickerModeDateTime) {
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    else if (self.formDatePickerMode == XLFormCustomDateDatePickerModeTime){
        datePicker.datePickerMode = UIDatePickerModeTime;
    }
    else{
        datePicker.datePickerMode = UIDatePickerModeDate;
    }
    
    if (self.minuteInterval)
        datePicker.minuteInterval = self.minuteInterval;
    
    if (self.minimumDate)
        datePicker.minimumDate = self.minimumDate;
    
    if (self.maximumDate)
        datePicker.maximumDate = self.maximumDate;
}

#pragma mark - event response
- (void)datePickerValueChanged:(UIDatePicker *)sender {
    self.rowDescriptor.value = sender.date;
    [self update];
    [self setNeedsLayout];
}

#pragma mark - setters and getters
- (void)setFormDatePickerMode:(XLFormCustomDateDatePickerMode)formDatePickerMode {
    _formDatePickerMode = formDatePickerMode;
    if ([self isFirstResponder]) {
        NSIndexPath * selectedRowPath = [self.formViewController.form indexPathOfFormRow:self.rowDescriptor];
        NSIndexPath * nextRowPath = [NSIndexPath indexPathForRow:selectedRowPath.row + 1 inSection:selectedRowPath.section];
        XLFormRowDescriptor * nextFormRow = [self.formViewController.form formRowAtIndex:nextRowPath];
        if ([nextFormRow.rowType isEqualToString:XLFormRowDescriptorTypeDatePicker]){
            XLFormDatePickerCell * datePickerCell = (XLFormDatePickerCell *)[nextFormRow cellForFormController:self.formViewController];
            [self setModeToDatePicker:datePickerCell.datePicker];
        }
    }
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        [_datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
