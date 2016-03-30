//
//  XLFTextValueCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFTextValueCell.h"
#import "NSString+Common.h"
#import "UIView+Common.h"

#define kPaddingLeftWidth 15
#define kTextFont       15
#define kValueFont      15

NSString * const XLFormRowDescriptorTypeTextValue = @"XLFormRowDescriptorTypeTextValue";

@interface XLFTextValueCell ()

@property (nonatomic, strong) UILabel *m_textLabel;
@property (nonatomic, strong) UILabel *m_valueLabel;
@property (nonatomic, strong) UIButton *m_editButton;
@end

@implementation XLFTextValueCell

+ (void)load {
    
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFTextValueCell class] forKey:XLFormRowDescriptorTypeTextValue];
}

- (void)configure {
    
    [super configure];
    
    [self.contentView addSubview:self.m_textLabel];
    [self.contentView addSubview:self.m_valueLabel];
    [self.contentView addSubview:self.m_editButton];
}

- (void)update {
    
    [super update];
    
    NSDictionary *dict = (NSDictionary*)self.rowDescriptor.value;
    
    
    // 是否能编辑
    if ([[dict objectForKey:@"isEdit"] integerValue]) {
        _m_editButton.hidden = NO;
        [_m_editButton setCenterY:[XLFTextValueCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor] / 2.f];
    }else {
        _m_editButton.hidden = YES;
    }
    
    _m_textLabel.text = [dict objectForKey:@"text"];
    
    CGRect frame = self.m_valueLabel.frame;

    if (![[dict objectForKey:@"value"] length] || [[dict objectForKey:@"value"] isEqualToString:@"<null>"]) {
        frame.size.height = 20;
        self.m_valueLabel.frame = frame;
        self.m_valueLabel.textColor = [UIColor lightGrayColor];
        self.m_valueLabel.text = @"未填写";
        return;
    }
    
    CGFloat height = [[dict objectForKey:@"value"] getHeightWithFont:[UIFont systemFontOfSize:kValueFont] constrainedToSize:CGSizeMake(kScreen_Width - kPaddingLeftWidth - 64, MAXFLOAT)];
    if (height > 20) {
        frame.size.height = height;
    }else {
        frame.size.height = 20;
    }
    self.m_valueLabel.frame = frame;
    self.m_valueLabel.textColor = [UIColor blackColor];
    self.m_valueLabel.text = [dict objectForKey:@"value"];
}

+(CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor
{
    // return custom cell size
    NSDictionary *dict = (NSDictionary*)rowDescriptor.value;
    
    CGFloat height = 50.0;
    if ([dict objectForKey:@"value"]) {
        if ([[dict objectForKey:@"value"] length]) {
            CGFloat h = [[dict objectForKey:@"value"] getHeightWithFont:[UIFont systemFontOfSize:kValueFont] constrainedToSize:CGSizeMake(kScreen_Width - kPaddingLeftWidth - 64, MAXFLOAT)];
            if (h > 20) {
                height += h;
            }else {
                height += 20;
            }
        }else {
            height += 20;
        }
    }
    return height;
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    NSLog(@"------当前点击行的信息%@----", self.rowDescriptor);
    if ([self.rowDescriptor.tag isEqualToString:@"business"]) {
        if ([self.rowDescriptor value] && [[[self.rowDescriptor value] allKeys] containsObject:@"isEdit"]) {
            if ([[[self.rowDescriptor value] objectForKey:@"isEdit"] integerValue] == 0) {
                BOOL hasAction = self.rowDescriptor.action.formBlock || self.rowDescriptor.action.formSelector;
                if (hasAction) {
                    if (self.rowDescriptor.action.formBlock) {
                        self.rowDescriptor.action.formBlock(self.rowDescriptor);
                    }
                }
            }
        }
    }
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - event response
- (void)editButtonPress {
    BOOL hasAction = self.rowDescriptor.action.formBlock || self.rowDescriptor.action.formSelector;
    if (hasAction) {
        if (self.rowDescriptor.action.formBlock) {
            self.rowDescriptor.action.formBlock(self.rowDescriptor);
        }
    }
}

#pragma mark - setters and getters
- (UILabel*)m_textLabel {
    if (!_m_textLabel) {
        _m_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10, kScreen_Width - 2 * kPaddingLeftWidth, 20)];
        _m_textLabel.font = [UIFont systemFontOfSize:kTextFont];
        _m_textLabel.textColor = [UIColor colorWithRed:(CGFloat)70/255.0 green:(CGFloat)154/255.0 blue:(CGFloat)234/255.0 alpha:1.0];
        _m_textLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_textLabel;
}

- (UILabel*)m_valueLabel {
    if (!_m_valueLabel) {
        _m_valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 10+20+10, kScreen_Width - kPaddingLeftWidth - 64, 0)];
        _m_valueLabel.font = [UIFont systemFontOfSize:kValueFont];
        _m_valueLabel.textAlignment = NSTextAlignmentLeft;
        _m_valueLabel.numberOfLines = 0;
        _m_valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _m_valueLabel;
}

- (UIButton*)m_editButton {
    if (!_m_editButton) {
        _m_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _m_editButton.frame = CGRectMake(kScreen_Width - 64, 0, 64, [XLFTextValueCell formDescriptorCellHeightForRowDescriptor:self.rowDescriptor]);
        [_m_editButton setImage:[UIImage imageNamed:@"edit_doc"] forState:UIControlStateNormal];
        [_m_editButton addTarget:self action:@selector(editButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _m_editButton;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
