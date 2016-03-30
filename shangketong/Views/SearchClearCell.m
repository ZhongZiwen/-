//
//  SearchClearCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SearchClearCell.h"

@interface SearchClearCell ()

@property (strong, nonatomic) UILabel *clearLabel;
@end

@implementation SearchClearCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_clearLabel) {
            _clearLabel = [[UILabel alloc] init];
            [_clearLabel setWidth:kScreen_Width];
            [_clearLabel setHeight:[SearchClearCell cellHeight]];
            _clearLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
            _clearLabel.textAlignment = NSTextAlignmentCenter;
            _clearLabel.textColor = [UIColor iOS7darkGrayColor];
            _clearLabel.text = @"清空搜索历史";
        }
        
        [self.contentView addSubview:_clearLabel];
    }
    return self;
}

+ (CGFloat)cellHeight {
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
