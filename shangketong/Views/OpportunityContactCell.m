//
//  OpportunityContactCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/12/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "OpportunityContactCell.h"
#import "Contact.h"

@interface OpportunityContactCell ()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIButton *phoneButton;
@property (strong, nonatomic) UIImageView *markImageView;
@end
@implementation OpportunityContactCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.phoneButton];
        [self.contentView addSubview:self.markImageView];
    }
    return self;
}

- (void)configWithItem:(Contact *)item {
    _nameLabel.text = item.name;
    _detailLabel.text = item.companyName;
    
    if ([item.isTouchLinkMan isEqualToNumber:@0]) {
        CGFloat width = [item.name getWidthWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 24)];
        _markImageView.hidden = NO;
        [_markImageView setX:15 + width + 10];
    }
    else {
        _markImageView.hidden = YES;
    }
    
    if (item.phone || item.mobile) {
        _phoneButton.hidden = NO;
    }
    else {
        _phoneButton.hidden = YES;
    }
}

- (void)phoneButtonPress {
    if (self.phoneBtnClickedBlock) {
        self.phoneBtnClickedBlock();
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

#pragma mark - setters and getters
- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setX:15];
        [_nameLabel setY:10];
        [_nameLabel setWidth:kScreen_Width - 15 - 64];
        [_nameLabel setHeight:24];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setX:CGRectGetMinX(_nameLabel.frame)];
        [_detailLabel setY:CGRectGetMaxY(_nameLabel.frame)];
        [_detailLabel setWidth:CGRectGetWidth(_nameLabel.bounds)];
        [_detailLabel setHeight:20];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.textColor = [UIColor lightGrayColor];
    }
    return _detailLabel;
}

- (UIButton*)phoneButton {
    if (!_phoneButton) {
        _phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phoneButton setX:kScreen_Width - 64.0f];
        [_phoneButton setWidth:64.0f];
        [_phoneButton setHeight:[OpportunityContactCell cellHeight]];
        [_phoneButton setImage:[UIImage imageNamed:@"colleagueCallBtn"] forState:UIControlStateNormal];
        [_phoneButton addTarget:self action:@selector(phoneButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phoneButton;
}

- (UIImageView*)markImageView {
    if (!_markImageView) {
        UIImage *image = [UIImage imageNamed:@"role_main_flg"];
        _markImageView = [[UIImageView alloc] initWithImage:image];
        [_markImageView setWidth:image.size.width];
        [_markImageView setHeight:image.size.height];
        [_markImageView setCenterY:CGRectGetMidY(_nameLabel.frame)];
    }
    return _markImageView;
}
@end
