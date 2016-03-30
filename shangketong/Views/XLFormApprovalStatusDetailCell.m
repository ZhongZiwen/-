//
//  XLFormApprovalStatusDetailCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormApprovalStatusDetailCell.h"
#import "PreviousRun.h"

NSString *const XLFormRowDescriptorTypeApprovalStatusDetail = @"XLFormRowDescriptorTypeApprovalStatusDetail";

@interface XLFormApprovalStatusDetailCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation XLFormApprovalStatusDetailCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormApprovalStatusDetailCell class] forKey:XLFormRowDescriptorTypeApprovalStatusDetail];
}

- (void)configure {
    [super configure];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.detailLabel];
}

- (void)update {
    [super update];
    
    PreviousRun *item = self.rowDescriptor.value;
    
    if (![item.status integerValue]) {
        _detailLabel.text = [NSString stringWithFormat:@"%@ 我拒绝了此申请", [item.approveTime stringTimestampWithoutYear]];
    }else {
        _detailLabel.text = [NSString stringWithFormat:@"%@ 我同意了此申请", [item.approveTime stringTimestampWithoutYear]];
    }
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 44.0f;
}

#pragma mark - setters and getters
- (UIImageView*)iconView {
    if (!_iconView) {
        UIImage *image = [UIImage imageNamed:@"tab_recent_normal"];
        _iconView = [[UIImageView alloc] initWithImage:image];
        [_iconView setX:15];
        [_iconView setWidth:image.size.width];
        [_iconView setHeight:image.size.height];
        [_iconView setCenterY:22.0f];
    }
    return _iconView;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_detailLabel setWidth:kScreen_Width - CGRectGetMinX(_detailLabel.frame) - 15];
        [_detailLabel setHeight:20];
        [_detailLabel setCenterY:CGRectGetMidY(_iconView.frame)];
        _detailLabel.font = [UIFont systemFontOfSize:13];
        _detailLabel.textColor = [UIColor iOS7lightGrayColor];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _detailLabel;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
