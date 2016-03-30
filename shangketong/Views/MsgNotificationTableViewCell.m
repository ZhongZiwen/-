//
//  MsgNotificationTableViewCell.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "MsgNotificationTableViewCell.h"
#import "CommonFuntion.h"

#define kImageView_Width    44

@interface MsgNotificationTableViewCell ()

@property (nonatomic, strong) UIImageView *m_imageView;
@property (nonatomic, strong) UILabel *m_titleLabel;
@property (nonatomic, strong) UIButton *m_badgeBtn;
@end

@implementation MsgNotificationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        _m_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, ([MsgNotificationTableViewCell cellHeight]-kImageView_Width)/2.0f, kImageView_Width, kImageView_Width)];
        [self.contentView addSubview:_m_imageView];
        
        _m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(2*_m_imageView.frame.origin.x+kImageView_Width, ([MsgNotificationTableViewCell cellHeight]-30)/2.0f, 180, 30)];
        _m_titleLabel.font = [UIFont systemFontOfSize:15];
        _m_titleLabel.textColor = [UIColor blackColor];
        _m_titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_m_titleLabel];
        
        _m_badgeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.contentView addSubview:_m_badgeBtn];
    }
    return self;
}

- (void)configImageView:(NSString *)imageStr andTitleLabel:(NSString *)titleStr andBadge:(NSInteger)count {
    _m_imageView.image = [UIImage imageNamed:imageStr];
    _m_titleLabel.text = titleStr;
    if (count) {
        CGFloat width = 19;
        if (count > 99) {
            width = 30;
        }
        _m_badgeBtn.frame = CGRectMake(kScreen_Width-30- width, ([MsgNotificationTableViewCell cellHeight]- 19)/2.0f, width, 19);
        _m_badgeBtn.layer.masksToBounds = YES;
        _m_badgeBtn.layer.cornerRadius = 9.5;
        UIImage *image = [CommonFuntion createImageWithColor:[UIColor colorWithHexString:@"f74c31"]];
        _m_badgeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [_m_badgeBtn setBackgroundImage:image forState:UIControlStateNormal];
        _m_badgeBtn.hidden = NO;
        _m_badgeBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_m_badgeBtn setTitle:[NSString stringWithFormat:@"%ld", count] forState:UIControlStateNormal];
    }else {
        _m_badgeBtn.hidden = YES;
    }
}

+ (CGFloat)cellHeight {
    return 64.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
