//
//  ExportBottomTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ExportBottomTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "AddressBook.h"

@interface ExportBottomTableViewCell ()

@property (nonatomic, weak) UIImageView *m_headImageView;
@end

@implementation ExportBottomTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, [ExportBottomTableViewCell cellHeight]-2*5, [ExportBottomTableViewCell cellHeight]-2*5)];
        headImageView.layer.cornerRadius = 5;
        headImageView.clipsToBounds = YES;
        headImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self.contentView addSubview:headImageView];
        _m_headImageView = headImageView;
    }
    return self;
}

- (void)configWithModel:(AddressBook *)model
{
    if (model.isDefault) {
        [_m_headImageView setImage:[UIImage imageNamed:model.icon]];
    }else{
        [_m_headImageView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    }
}

+ (CGFloat)cellHeight
{
    return 54.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
