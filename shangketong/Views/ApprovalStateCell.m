//
//  ApprovalStateCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalStateCell.h"
#import "NSString+Common.h"

@interface ApprovalStateCell ()

@property (nonatomic, strong) UIImageView *m_resultImageView;
@property (nonatomic, strong) UILabel *m_timeLabel;
@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_contentLabel;
@end

@implementation ApprovalStateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 0.5, [ApprovalStateCell cellHeight])];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:lineView];
        
        [self.contentView addSubview:self.m_resultImageView];
        [self.contentView addSubview:self.m_timeLabel];
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_contentLabel];
    }
    return self;
}

- (void)configWithProcessType:(ProcessType)type andDictionary:(NSDictionary *)dict andLastObjec:(BOOL)isLast {
    
    if (isLast) {
        _m_resultImageView.image = [UIImage imageNamed:@"UMS_follow_on"];
        _m_timeLabel.textColor = [UIColor greenColor];
        _m_contentLabel.textColor = [UIColor greenColor];
    }else {
        _m_resultImageView.image = [UIImage imageNamed:@"UMS_follow_off"];
        _m_timeLabel.textColor = [UIColor blackColor];
        _m_contentLabel.textColor = [UIColor blackColor];
    }
    
    if (type == ProcessTypeApply) { // 申请人
        _m_timeLabel.text = [NSString msgRemindApprovalTransDateWithTimeInterval:[dict objectForKey:@"updatedAt"]];
        _m_contentLabel.text = [NSString stringWithFormat:@"%@ 提交审核", [[dict objectForKey:@"createdBy"] objectForKey:@"name"]];
        return;
    }
    
    // 审批人
    _m_timeLabel.text = [NSString msgRemindApprovalTransDateWithTimeInterval:[dict objectForKey:@"approvalTime"]];
    _m_contentLabel.text = [NSString stringWithFormat:@"%@ %@", [[dict objectForKey:@"approvalUser"] objectForKey:@"name"], ([[dict objectForKey:@"result"] integerValue] ? @"同意" : @"拒绝")];
    
}

+ (CGFloat)cellHeight {
    return 75.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UIImageView*)m_resultImageView {
    if (!_m_resultImageView) {
        UIImage *image = [UIImage imageNamed:@"UMS_follow_off"];
        _m_resultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20.25 - image.size.width / 2.0, 15, image.size.width, image.size.height)];
        
    }
    return _m_resultImageView;
}

- (UILabel*)m_timeLabel {
    if (!_m_timeLabel) {
        _m_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20 + 15, 10, 200, 15)];
        _m_timeLabel.font = [UIFont systemFontOfSize:12];
        _m_timeLabel.textColor = [UIColor blackColor];
        _m_timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_timeLabel;
}

- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_m_timeLabel.frame.origin.x, 20 + CGRectGetHeight(_m_timeLabel.bounds), 30, 30)];
        _m_imageView.image = [UIImage imageNamed:@"user_icon_default_90"];
    }
    return _m_imageView;
}

- (UILabel*)m_contentLabel {
    if (!_m_contentLabel) {
        _m_contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_imageView.frame.origin.x + CGRectGetWidth(_m_imageView.bounds) + 10, _m_imageView.frame.origin.y, 200, CGRectGetHeight(_m_imageView.bounds))];
        _m_contentLabel.font = [UIFont systemFontOfSize:14];
        _m_contentLabel.textColor = [UIColor blackColor];
        _m_contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_contentLabel;
}

@end
