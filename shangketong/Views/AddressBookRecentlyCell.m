//
//  AddressBookRecentlyCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookRecentlyCell.h"
#import "AddressBook.h"

@interface AddressBookRecentlyCell ()

@property (strong, nonatomic) NSArray *recentlyArray;
@end

@implementation AddressBookRecentlyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        for (int i = 0; i < 5; i ++) {
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellLeftWidth + (44 + kCellLeftWidth) * i, 10, 44, 44)];
            iconView.tag = 200 + i;
            iconView.contentMode = UIViewContentModeScaleAspectFill;
            iconView.layer.cornerRadius = 5;
            iconView.clipsToBounds = YES;
            iconView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconViewTag:)];
            [iconView addGestureRecognizer:tap];
            [self.contentView addSubview:iconView];
            
            UILabel *nameLabel = [[UILabel alloc] init];
            [nameLabel setX:CGRectGetMinX(iconView.frame)];
            [nameLabel setY:CGRectGetMaxY(iconView.frame) + 5];
            [nameLabel setWidth:CGRectGetWidth(iconView.bounds)];
            [nameLabel setHeight:20];
            nameLabel.tag = 300 + i;
            nameLabel.font = [UIFont systemFontOfSize:13];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:nameLabel];
        }
    }
    return self;
}

- (void)configWithArray:(NSArray *)array {
    _recentlyArray = array;
    
    for (int i = 0; i < 5; i ++) {
        UIImageView *iconView = (UIImageView*)[self.contentView viewWithTag:200 + i];
        UILabel *nameLabel = (UILabel*)[self.contentView viewWithTag:300 + i];
        if (i < _recentlyArray.count) {
            AddressBook *item = _recentlyArray[i];
            iconView.hidden = NO;
            [iconView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
            nameLabel.hidden = NO;
            nameLabel.text = item.name;
        }else {
            iconView.hidden = YES;
            nameLabel.hidden = YES;
        }
    }
}

- (void)iconViewTag:(UITapGestureRecognizer*)sender {
    UIImageView *iconView = (UIImageView*)sender.view;
    AddressBook *item = _recentlyArray[iconView.tag - 200];
    
    if (self.iconViewTapBlock) {
        self.iconViewTapBlock(item);
    }
}

+ (CGFloat)cellHeight {
    return 84.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
