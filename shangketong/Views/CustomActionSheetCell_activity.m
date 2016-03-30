//
//  CustomActionSheetCell_activity.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomActionSheetCell_activity.h"
#import "ColumnSelectModel.h"

@interface CustomActionSheetCell_activity ()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *typeImageView;
@end

@implementation CustomActionSheetCell_activity

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.typeImageView];
    }
    return self;
}

- (void)configWithModel:(ColumnSelectModel *)model {
    
    _nameLabel.text = model.value;
    
    UIImage *typeImage;
    if ([model.id isEqualToString:@"A001"]) {
        typeImage = [UIImage imageNamed:@"activity_select_discuss"];
    }else if ([model.id isEqualToString:@"A002"]) {
        typeImage = [UIImage imageNamed:@"activity_select_phone"];
    }else if ([model.id isEqualToString:@"A003"]) {
        typeImage = [UIImage imageNamed:@"activity_select_pos"];
    }else {
        typeImage = [UIImage imageNamed:@"activity_select_other"];
    }
    [_typeImageView setWidth:typeImage.size.width];
    [_typeImageView setHeight:typeImage.size.height];
    [_typeImageView setCenterX:kScreen_Width - 25];
    [_typeImageView setCenterY:CGRectGetMidY(_nameLabel.frame)];
    _typeImageView.image = typeImage;
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
        [_nameLabel setWidth:kScreen_Width - 15 - 44];
        [_nameLabel setHeight:20];
        [_nameLabel setCenterY:48.0f / 2.0];
        _nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
        _nameLabel.textColor = kNavigationTintColor;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _nameLabel;
}

- (UIImageView*)typeImageView {
    if (!_typeImageView) {
        _typeImageView = [[UIImageView alloc] init];
    }
    return _typeImageView;
}
@end
