//
//  RecordDetail_commentCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RecordDetail_commentCell.h"
#import "Comment.h"

@interface RecordDetail_commentCell ()

@property (strong, nonatomic) UILabel *timeLabel;
@end

@implementation RecordDetail_commentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.iconImageView];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.timeLabel];
    }
    return self;
}

- (void)configWithObj:(Comment *)obj {
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:obj.creator.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    
    [_contentLabel setWidth:kScreen_Width - CGRectGetMinX(_contentLabel.frame) - 15];
    _contentLabel.text = obj.content;
    [_contentLabel sizeToFit];
    
    for (User *tempUser in obj.altsArray) {
        
        // 找到重名的用户
        NSMutableArray *altUsersArray = [NSMutableArray arrayWithCapacity:0];
        for (User *altUser in obj.altsArray) {
            if ([altUser.name rangeOfString:tempUser.name].location != NSNotFound) {
                [altUsersArray addObject:altUser];
            }
        }
        
        // 从内容中找到@人的range
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:0];
        NSRange searchRange = NSMakeRange(0, [obj.content length]);
        NSRange altRange;
        while ((altRange = [obj.content rangeOfString:[NSString stringWithFormat:@"@%@", tempUser.name] options:0 range:searchRange]).location != NSNotFound) {
            [resultsArray addObject:[NSValue valueWithRange:altRange]];
            searchRange = NSMakeRange(NSMaxRange(altRange), [obj.content length] - NSMaxRange(altRange));
        }
        
        NSInteger index = [altUsersArray indexOfObject:tempUser];
        
        if (index < resultsArray.count) {
            NSRange range = ((NSValue*)resultsArray[index]).rangeValue;
            [_contentLabel addLinkToTransitInformation:@{@"user" : tempUser} withRange:range];
        }
        
    }
    
    [_timeLabel setY:CGRectGetMaxY(_contentLabel.frame) + 5];
//    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", obj.creator.name, [obj.date stringDisplay_HHmm]];
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", obj.creator.name, [CommonFuntion commentOrTrendsDateCommonByDate:obj.date]];    
}

+ (CGFloat)cellHeightWithObj:(Comment *)obj {
    CGFloat cellHeight = 0;
    
    cellHeight += 10;
    
    CGFloat contentHeight = [obj.content getHeightWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(kScreen_Width - 15 - 10 - 35 - 15, CGFLOAT_MAX)];
    cellHeight += contentHeight;
    cellHeight += 5;
    cellHeight += 20;
    cellHeight += 10;
    
    return cellHeight;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UITapImageView*)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UITapImageView alloc] init];
        [_iconImageView setX:15];
        [_iconImageView setY:10];
        [_iconImageView setWidth:35];
        [_iconImageView setHeight:35];
    }
    return _iconImageView;
}

- (TTTAttributedLabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_iconImageView.frame) + 10, CGRectGetMinY(_iconImageView.frame), kScreen_Width - CGRectGetMinX(_contentLabel.frame) - 15, 20)];
        _contentLabel.font = [UIFont systemFontOfSize:15];
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
        _contentLabel.numberOfLines = 0;
        _contentLabel.linkAttributes = kLinkAttributes;
        _contentLabel.activeLinkAttributes = kLinkAttributesActive;
    }
    return _contentLabel;
}

- (UILabel*)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setX:CGRectGetMinX(_contentLabel.frame)];
        [_timeLabel setWidth:kScreen_Width - CGRectGetMinX(_timeLabel.frame) - 15];
        [_timeLabel setHeight:20];
        _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _timeLabel;
}
@end
