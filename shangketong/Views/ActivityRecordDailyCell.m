//
//  ActivityRecordDailyCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ActivityRecordDailyCell.h"
#import "ActivityType.h"
#import "Activity.h"

#define kBGView_width 140
@interface ActivityRecordDailyCell ()

@property (strong, nonatomic) UIButton *bgButton;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *sumLabel;

@end

@implementation ActivityRecordDailyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.bgButton];
        [_bgButton addSubview:self.nameLabel];
        [_bgButton addSubview:self.sumLabel];
    }
    return self;
}

- (void)configWithModel:(ActivityType *)model {
    _nameLabel.text = model.name;
    _sumLabel.text = [NSString stringWithFormat:@"%@", model.sum];
}

+ (CGFloat)cellHeight {
    return 170;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)changeColor:(UIButton*)sender {
    sender.layer.borderColor = [UIColor iOS7pinkColor].CGColor;
}

- (void)resetColor:(UIButton*)sender {
    sender.layer.borderColor = [UIColor iOS7lightGrayColor].CGColor;
}

- (void)bgButtonPress:(UIButton*)sender {
    sender.layer.borderColor = [UIColor iOS7lightGrayColor].CGColor;
    
    if (self.popBlock) {
        self.popBlock();
    }
}

#pragma mark - setters and getters
- (UIButton*)bgButton {
    if (!_bgButton) {
        _bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bgButton setWidth:kBGView_width];
        [_bgButton setHeight:kBGView_width];
        [_bgButton setCenterX:kScreen_Width / 2];
        [_bgButton setCenterY:[ActivityRecordDailyCell cellHeight] / 2];
        _bgButton.layer.cornerRadius = kBGView_width / 2;
        _bgButton.layer.borderWidth = 2;
        _bgButton.layer.borderColor = [UIColor iOS7lightGrayColor].CGColor;
        [_bgButton addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
        [_bgButton addTarget:self action:@selector(resetColor:) forControlEvents:UIControlEventTouchDragExit];
        [_bgButton addTarget:self action:@selector(bgButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgButton;
}

- (UILabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setY:20];
        [_nameLabel setWidth:kBGView_width];
        [_nameLabel setHeight:15];
        [_nameLabel setCenterX:kBGView_width / 2];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

- (UILabel*)sumLabel {
    if (!_sumLabel) {
        _sumLabel = [[UILabel alloc] init];
        [_sumLabel setWidth:kBGView_width];
        [_sumLabel setHeight:44];
        [_sumLabel setCenterX:kBGView_width / 2];
        [_sumLabel setCenterY:kBGView_width / 2 + 10];
        _sumLabel.font = [UIFont systemFontOfSize:45];
        _sumLabel.textColor = [UIColor iOS7pinkColor];
        _sumLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sumLabel;
}

@end
