//
//  ApprovalListCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalListCell.h"
#import "CRM_Approval.h"

@interface ApprovalListCell ()

@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation ApprovalListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    CRM_Approval *item = (CRM_Approval*)obj;
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:item.creator.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    _titleLabel.text = [NSString stringWithFormat:@"[%@]", item.approveNo];
    if ([item.approveStatus isEqualToNumber:@1]) {  // 审批中
        _detailLabel.text = [NSString stringWithFormat:@"%@ 等待 %@ 审批", [item.createdAt stringTimestampWithoutYear], item.approver.name];
    }
    else if ([item.approveStatus isEqualToNumber:@2]) {  // 已撤销
        _detailLabel.text = [NSString stringWithFormat:@"%@ 已撤回", [item.createdAt stringTimestampWithoutYear]];
    }
    else if ([item.approveStatus isEqualToNumber:@3]) {  // 已通过
        _detailLabel.text = [NSString stringWithFormat:@"%@", [item.createdAt stringTimestampWithoutYear]];
    }
    else if ([item.approveStatus isEqualToNumber:@4]) {  // 拒绝
        _detailLabel.text = [NSString stringWithFormat:@"%@ 被 %@ 拒绝", [item.createdAt stringTimestampWithoutYear], item.approver.name];
    }
}

+ (CGFloat)cellHeight {
    return 54.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        [_iconView setX:15];
        [_iconView setWidth:34];
        [_iconView setHeight:34];
        [_iconView setCenterY:[ApprovalListCell cellHeight] / 2];
    }
    return _iconView;
}

- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_titleLabel setY:10];
        [_titleLabel setWidth:kScreen_Width - CGRectGetMinX(_titleLabel.frame) - 30];
        [_titleLabel setHeight:20];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMaxX(_iconView.frame) + 10];
        [_detailLabel setY:CGRectGetMaxY(_titleLabel.frame)];
        [_detailLabel setWidth:CGRectGetWidth(_titleLabel.bounds)];
        [_detailLabel setHeight:14];
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _detailLabel.textColor = [UIColor iOS7lightGrayColor];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _detailLabel;
}

@end
