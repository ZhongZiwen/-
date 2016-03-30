//
//  ActivityRecordTypeListCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordTypeListCell.h"
#import "Activity.h"

@interface ActivityRecordTypeListCell ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation ActivityRecordTypeListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
    }
    return self;
}

- (void)configWithModel:(Activity *)item {
    _titleLabel.text = item.someDay;
    _detailLabel.text = [NSString stringWithFormat:@"%@", item.number];
}

+ (CGFloat)cellHeight {
    return 44.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UILabel*)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setX:15];
        [_titleLabel setWidth:200];
        [_titleLabel setHeight:[ActivityRecordTypeListCell cellHeight]];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel*)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        [_detailLabel setWidth:64];
        [_detailLabel setHeight:[ActivityRecordTypeListCell cellHeight]];
        [_detailLabel setX:kScreen_Width - 30 - CGRectGetWidth(_detailLabel.bounds)];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = [UIColor iOS7darkGrayColor];
        _detailLabel.textAlignment = NSTextAlignmentRight;
    }
    return _detailLabel;
}

@end
