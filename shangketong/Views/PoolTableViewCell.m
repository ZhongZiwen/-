//
//  PoolTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PoolTableViewCell.h"
#import "PoolGroup.h"

@interface PoolTableViewCell ()

@property (strong, nonatomic) UILabel *m_title;
@property (strong, nonatomic) UILabel *m_detail;
@end

@implementation PoolTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self.contentView addSubview:self.m_title];
        [self.contentView addSubview:self.m_detail];
    }
    return self;
}

- (void)configWithModel:(PoolGroup *)group {
    _m_title.text = group.name;
    _m_detail.text = [NSString stringWithFormat:@"待领取(%@)", group.waitToGetCount];
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

- (UILabel*)m_title {
    if (!_m_title) {
        _m_title = [[UILabel alloc] init];
        [_m_title setX:15];
        [_m_title setWidth:kScreen_Width - 15 - 80 - 30];
        [_m_title setHeight:20];
        [_m_title setCenterY:[PoolTableViewCell cellHeight] / 2];
        _m_title.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        _m_title.textAlignment = NSTextAlignmentLeft;
    }
    return _m_title;
}

- (UILabel*)m_detail {
    if (!_m_detail) {
        _m_detail = [[UILabel alloc] init];
        [_m_detail setWidth:80];
        [_m_detail setHeight:20];
        [_m_detail setX:kScreen_Width - CGRectGetWidth(_m_detail.bounds) - 30];
        [_m_detail setCenterY:CGRectGetMidY(_m_title.frame)];
        _m_detail.font = [UIFont systemFontOfSize:14];
        _m_detail.textColor = [UIColor iOS7darkGrayColor];
        _m_detail.textAlignment = NSTextAlignmentRight;
    }
    return _m_detail;
}

@end
