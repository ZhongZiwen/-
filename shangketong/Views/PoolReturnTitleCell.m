//
//  PoolReturnTitleCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PoolReturnTitleCell.h"

@interface PoolReturnTitleCell ()

@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation PoolReturnTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] init];
            [_titleLabel setX:15];
            [_titleLabel setY:15];
            [_titleLabel setWidth:kScreen_Width - 30];
            _titleLabel.font = [UIFont systemFontOfSize:14];
            _titleLabel.textAlignment = NSTextAlignmentLeft;
            _titleLabel.numberOfLines = 0;
            _titleLabel.textColor = [UIColor iOS7darkGrayColor];
            [self.contentView addSubview:_titleLabel];
        }
    }
    return self;
}

- (void)configWithString:(NSString *)str {
    
    NSString *title = [NSString stringWithFormat:@"退回后，该销售线索[%@]可能被其他人员认领，你也可以重新认领", str];
    
    CGFloat height = [title getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
    
    [_titleLabel setHeight:height];
    _titleLabel.text = title;
}

+ (CGFloat)cellHeightWithString:(NSString *)str {
    
    NSString *title = [NSString stringWithFormat:@"退回后，该销售线索[%@]可能被其他人员认领，你也可以重新认领", str];
    
    CGFloat height = [title getHeightWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(kScreen_Width - 30, CGFLOAT_MAX)];
    return height + 30;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
