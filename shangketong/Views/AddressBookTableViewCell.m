//
//  AddressBookTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBookTableViewCell.h"
#import "AddressBook.h"
#import "DepartGroupModel.h"

@interface AddressBookTableViewCell ()

@property (nonatomic, weak) UIImageView *m_headView;
@property (nonatomic, weak) UILabel *m_nameLabel;
@property (nonatomic, weak) UILabel *m_departLabel;
@property (nonatomic, weak) UIButton *m_callButton;
@property (nonatomic, weak) UIImageView *m_accessoryImageView;
@end

@implementation AddressBookTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellLeftWidth, 10, [AddressBookTableViewCell cellHeight]-2*10, [AddressBookTableViewCell cellHeight]-2*10)];
        headView.contentMode = UIViewContentModeScaleAspectFill;
        headView.layer.cornerRadius = 5;
        headView.clipsToBounds = YES;
        [self.contentView addSubview:headView];
        _m_headView = headView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        [nameLabel setX:CGRectGetMaxX(headView.frame) + kCellLeftWidth];
        [nameLabel setWidth:kScreen_Width - CGRectGetMinX(nameLabel.frame) - 40];
        [nameLabel setHeight:24];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = kCellTitleColor;
        nameLabel.font = kCellTitleFont;
        [self.contentView addSubview:nameLabel];
        _m_nameLabel = nameLabel;
        
        UILabel *departLabel = [[UILabel alloc] initWithFrame:CGRectMake(_m_nameLabel.frame.origin.x, 0, 250, 20)];
        departLabel.textAlignment = NSTextAlignmentLeft;
        departLabel.textColor = [UIColor lightGrayColor];
        departLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:departLabel];
        _m_departLabel = departLabel;
        
        UIImage *callImage = [UIImage imageNamed:@"colleagueCallBtn"];
        UIButton *callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        callButton.frame = CGRectMake(kScreen_Width - [AddressBookTableViewCell cellHeight], 0, [AddressBookTableViewCell cellHeight], [AddressBookTableViewCell cellHeight]);
        [callButton setImage:callImage forState:UIControlStateNormal];
        [callButton addTarget:self action:@selector(callButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:callButton];
        _m_callButton = callButton;
        
        UIImage *accessoryImage = [UIImage imageNamed:@"activity_Arrow"];
        UIImageView *accessoryImageView = [[UIImageView alloc] initWithImage:accessoryImage];
        [accessoryImageView setWidth:accessoryImage.size.width];
        [accessoryImageView setHeight:accessoryImage.size.height];
        [accessoryImageView setCenterX:kScreen_Width - 20];
        [accessoryImageView setCenterY:[AddressBookTableViewCell cellHeight] / 2];
        [self.contentView addSubview:accessoryImageView];
        _m_accessoryImageView = accessoryImageView;
    }
    return self;
}

- (void)callButtonPress {
    if (self.phoneBtnClickedBlock) {
        self.phoneBtnClickedBlock();
    }
}

- (void)configWithImageOfName:(NSString *)name title:(NSString *)title {
    _m_departLabel.hidden = YES;
    _m_callButton.hidden = YES;
    _m_accessoryImageView.hidden = NO;
    
    _m_headView.image = [UIImage imageNamed:name];
    [_m_nameLabel setCenterY:_m_headView.center.y];
    _m_nameLabel.text = title;
}

- (void)configDepartGroupWithModel:(DepartGroupModel *)model type:(NSInteger)type {
    _m_departLabel.hidden = YES;
    _m_callButton.hidden = YES;
    _m_accessoryImageView.hidden = NO;
    
    if (!type) {  // 公司部门
        _m_headView.image = [UIImage imageNamed:@"depart_icon"];
    }else {  // 群组
        [_m_headView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"Department_default"]];
    }
    
    [_m_nameLabel setCenterY:_m_headView.center.y];
    if (model.count.integerValue > 0) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%@)", model.name, model.count]];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(model.name.length, [str length] - model.name.length)];
        _m_nameLabel.attributedText = str;
    }
    else {
        _m_nameLabel.text = model.name;
    }
}

- (void)configWithModel:(AddressBook *)model {
    _m_accessoryImageView.hidden = YES;
    
    [_m_headView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    
    [_m_nameLabel setY:_m_headView.frame.origin.y];
    _m_nameLabel.text = model.name;
    
    [_m_departLabel setY:_m_nameLabel.frame.origin.y+CGRectGetHeight(_m_nameLabel.bounds)];
    _m_departLabel.hidden = NO;
    if (model.position) {
        _m_departLabel.text = [NSString stringWithFormat:@"%@ | %@", model.depart, model.position];
    }else {
        _m_departLabel.text = model.depart;
    }
    
    if ([model.phone length] || [model.mobile length]) {
        _m_callButton.hidden = NO;
    }else {
        _m_callButton.hidden = YES;
    }
}

- (void)configWithoutButtonWithModel:(AddressBook *)model {
    _m_accessoryImageView.hidden = YES;
    
    [_m_headView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
    
    [_m_nameLabel setY:_m_headView.frame.origin.y];
    _m_nameLabel.text = model.name;
    
    [_m_departLabel setY:_m_nameLabel.frame.origin.y+CGRectGetHeight(_m_nameLabel.bounds)];
    _m_departLabel.hidden = NO;
    _m_departLabel.text = model.depart;
    
    _m_callButton.hidden = YES;
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
