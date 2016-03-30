//
//  XLFormApprovalStatusCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormApprovalStatusCell.h"
#import "Examine.h"

#define kPaddingLeftWidth 15

NSString *const XLFormRowDescriptorTypeApprovalStatus = @"XLFormRowDescriptorTypeApprovalStatus";

@interface XLFormApprovalStatusCell ()

@property (strong, nonatomic) UIImageView *statusView;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation XLFormApprovalStatusCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[XLFormApprovalStatusCell class] forKey:XLFormRowDescriptorTypeApprovalStatus];
}

- (void)configure {
    [super configure];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [self.contentView addSubview:self.statusView];
    [self.contentView addSubview:self.statusLabel];
    [self.contentView addSubview:self.detailLabel];
}

- (void)update {
    [super update];
    
    Examine *examine = self.rowDescriptor.value;
    
    switch ([examine.approveStatus integerValue]) {
        case 1: {   // 等待审批
            _statusView.image = [UIImage imageNamed:@"approval_wait"];
            _detailLabel.text = [NSString stringWithFormat:@"等待 %@审批", examine.reviewUsers.name];
        }
            break;
        case 2: {   // 撤回
            _statusView.image = [UIImage imageNamed:@"approval_fail"];
            _detailLabel.text = [NSString stringWithFormat:@"%@ 已撤回", [examine.reviewTime stringTimestampWithoutYear]];
        }
            break;
        case 3: {   // 通过审批
            _statusView.image = [UIImage imageNamed:@"approval_sucess"];
            _detailLabel.text = @"已通过";
        }
            break;
        default: {  // 拒绝
            _statusView.image = [UIImage imageNamed:@"approval_fail"];
            _detailLabel.text = [NSString stringWithFormat:@"%@ 被 %@ 拒绝", [examine.reviewTime stringTimestampWithoutYear], examine.reviewUsers.name];
        }
            break;
    }
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    if (self.rowDescriptor.action.formSelector) {
        [controller performFormSelector:self.rowDescriptor.action.formSelector withObject:self.rowDescriptor];
    }
    
    [self.formViewController.tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 54.0f;
}

#pragma mark - setters and getters
- (UIImageView*)statusView {
    if (!_statusView) {
        _statusView = [[UIImageView alloc] init];
        [_statusView setX:15];
        [_statusView setWidth:10];
        [_statusView setHeight:10];
        [_statusView setCenterY:27.0f];
    }
    return _statusView;
}

- (UILabel*)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] init];
        [_statusLabel setX:CGRectGetMaxX(_statusView.frame) + 10];
        [_statusLabel setWidth:64];
        [_statusLabel setHeight:20];
        [_statusLabel setCenterY:27.0f];
        _statusLabel.font = [UIFont systemFontOfSize:16];
        _statusLabel.textAlignment = NSTextAlignmentLeft;
        _statusLabel.text = @"审批状态";
    }
    return _statusLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMaxX(_statusLabel.frame) + 10];
        [_detailLabel setWidth:kScreen_Width - CGRectGetMinX(_detailLabel.frame) - 30];
        [_detailLabel setHeight:20];
        [_detailLabel setCenterY:CGRectGetMidY(_statusView.frame)];
        _detailLabel.font = [UIFont systemFontOfSize:13];
        _detailLabel.textAlignment = NSTextAlignmentRight;
        _detailLabel.textColor = [UIColor iOS7lightGrayColor];
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
