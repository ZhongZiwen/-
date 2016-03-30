//
//  XLFormApprovalRemarkCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormApprovalRemarkCell.h"

NSString *const XLFormRowDescriptorTypeApprovalRemark = @"XLFormRowDescriptorTypeApprovalRemark";

@interface XLFormApprovalRemarkCell ()

@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UILabel *remarkLabel;
@end

@implementation XLFormApprovalRemarkCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormApprovalRemarkCell class] forKey:XLFormRowDescriptorTypeApprovalRemark];
}

- (void)configure {
    [super configure];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.bgView];
    [_bgView addSubview:self.remarkLabel];
}

- (void)update {
    [super update];
    
    NSString *remark = self.rowDescriptor.value;
    
    CGFloat height = [remark getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
    [_bgView setHeight:height + 30];
    [_remarkLabel setHeight:height];
    _remarkLabel.text = remark;
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    NSString *remark = rowDescriptor.value;
    
    CGFloat height = [remark getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
    return height + 30 + 20;
}

#pragma mark - setters and getters
- (UIView*)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        [_bgView setX:15];
        [_bgView setWidth:kScreen_Width - 30];
        [_bgView setBackgroundColor:[UIColor colorWithRed:0.98 green:0.078 blue:0.14 alpha:0.15]];
        _bgView.layer.borderWidth = 0.5;
        _bgView.layer.borderColor = [UIColor iOS7redColor].CGColor;
    }
    return _bgView;
}

- (UILabel*)remarkLabel {
    if (!_remarkLabel) {
        _remarkLabel = [[UILabel alloc] init];
        [_remarkLabel setX:15];
        [_remarkLabel setY:15];
        [_remarkLabel setWidth:CGRectGetWidth(_bgView.bounds) - 30];
        _remarkLabel.numberOfLines = 0;
        _remarkLabel.font = [UIFont systemFontOfSize:14];
        _remarkLabel.textAlignment = NSTextAlignmentLeft;
        _remarkLabel.textColor = [UIColor iOS7redColor];
    }
    return _remarkLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
