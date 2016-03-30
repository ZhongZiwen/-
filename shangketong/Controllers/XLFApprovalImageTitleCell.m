//
//  XLFApprovalImageTitleCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFApprovalImageTitleCell.h"
#import "UIView+Common.h"

NSString * const XLFormRowDescriptorTypeApprovalImageTitle = @"XLFormRowDescriptorTypeApprovalImageTitle";

@interface XLFApprovalImageTitleCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_titleLabel;
@end

@implementation XLFApprovalImageTitleCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFApprovalImageTitleCell class] forKey:XLFormRowDescriptorTypeApprovalImageTitle];
}

- (void)configure {
    [super configure];
    
    [self.contentView addSubview:self.m_imageView];
    [self.contentView addSubview:self.m_titleLabel];
}

- (void)update {
    [super update];
    
    NSDictionary *sourceDict = (NSDictionary*)self.rowDescriptor.value;
    
    NSArray *titleArray = @[@"我拒绝了此审批", @"我同意了此审批"];
    _m_titleLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString transDateWithTimeInterval:sourceDict[@"approveTime"] andCustomFormate:@"MM-dd HH:mm"], titleArray[[sourceDict[@"status"] integerValue]]];
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 44.0f;
}

#pragma mark - setters and getters
- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_recent_normal"]];
        _m_imageView.frame = CGRectMake(15, 0, 20, 20);
        [_m_imageView setCenterY:22.0];
    }
    return _m_imageView;
}

- (UILabel*)m_titleLabel {
    if (!_m_titleLabel) {
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25 + 20, 0, kScreen_Width - 25 - 20 - 10, 44)];
        _m_titleLabel.font = [UIFont systemFontOfSize:14];
        _m_titleLabel.textColor = [UIColor lightGrayColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_titleLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
