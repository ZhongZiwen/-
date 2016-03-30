//
//  MRCommentCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MRCommentCell.h"
#import "MRCommentModel.h"
#import "NSString+Common.h"

@interface MRCommentCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_nameLabel;
@property (nonatomic, strong) UILabel *m_timeLabel;
@property (nonatomic, strong) UILabel *m_contentLabel;
@end

@implementation MRCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.m_imageView];
        [self.contentView addSubview:self.m_nameLabel];
        [self.contentView addSubview:self.m_timeLabel];
        [self.contentView addSubview:self.m_contentLabel];
    }
    return self;
}

- (void)configWithModel:(MRCommentModel *)model {
    _m_nameLabel.text = model.user_name;
    _m_timeLabel.text = [NSString msgRemindApprovalTransDateWithTimeInterval:model.m_time];
    
    CGFloat height = [model.m_content getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - _m_nameLabel.frame.origin.x - 10, MAXFLOAT)];
    CGRect frame = _m_contentLabel.frame;
    frame.size.height = height;
    _m_contentLabel.frame = frame;
    _m_contentLabel.text = model.m_content;
}

+ (CGFloat)cellHeightWithModel:(MRCommentModel *)model {
    CGFloat height = [model.m_content getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 10 - 44 - 10 - 10, MAXFLOAT)];
    if ((10+20+10+height+10) > (44 + 10 + 10)) {
        return 10 + 20 + 10 + height +10;
    }else {
        return 44 + 10 + 10;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark- setters and getters
- (UIImageView*)m_imageView {
    if (!_m_imageView) {
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 44, 44)];
        _m_imageView.image = [UIImage imageNamed:@"user_icon_default_90"];
        
    }
    return _m_imageView;
}

- (UILabel*)m_nameLabel {
    if (!_m_nameLabel) {
        _m_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_imageView.frame.origin.x + CGRectGetWidth(_m_imageView.bounds) + 10, _m_imageView.frame.origin.y, 100, 20)];
        _m_nameLabel.font = [UIFont systemFontOfSize:14];
        _m_nameLabel.textColor = [UIColor blackColor];
        _m_nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _m_nameLabel;
}

- (UILabel*)m_timeLabel {
    if (!_m_timeLabel) {
        _m_timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width - 100 - 10, _m_nameLabel.frame.origin.y, 100, 20)];
        _m_timeLabel.font = [UIFont systemFontOfSize:12];
        _m_timeLabel.textColor = [UIColor lightGrayColor];
        _m_timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _m_timeLabel;
}

- (UILabel*)m_contentLabel {
    if (!_m_contentLabel) {
        _m_contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_nameLabel.frame.origin.x, _m_nameLabel.frame.origin.y + CGRectGetHeight(_m_nameLabel.bounds) + 10, kScreen_Width - _m_nameLabel.frame.origin.x - 10, 0)];
        _m_contentLabel.font = [UIFont systemFontOfSize:14];
        _m_contentLabel.textColor = [UIColor blackColor];
        _m_contentLabel.numberOfLines = 0;
        _m_contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _m_contentLabel;
}

@end
