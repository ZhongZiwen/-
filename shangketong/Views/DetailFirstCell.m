//
//  DetailFirstCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailFirstCell.h"

@interface DetailFirstCell ()

@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@end

@implementation DetailFirstCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"0xF8F8F8"];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.segmentedControl];
    }
    return self;
}

- (void)valueChanged:(UISegmentedControl*)sender {
    if (self.valueBlock) {
        self.valueBlock(sender.selectedSegmentIndex);
    }
}

+ (CGFloat)cellHeight {
    return 54;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setters and getters
- (UISegmentedControl*)segmentedControl {
    if (!_segmentedControl) {
        NSArray *array = @[@"跟进记录", @"详细资料"];
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:array];
        [_segmentedControl setX:15];
        [_segmentedControl setY:10];
        [_segmentedControl setWidth:kScreen_Width - 30];
        [_segmentedControl setHeight:[DetailFirstCell cellHeight] - 2*CGRectGetMinY(_segmentedControl.frame)];
        _segmentedControl.selectedSegmentIndex = 0;
        // 选中背景色调整：e1e8ed，字体颜色bec6cd；未选中框颜色
        _segmentedControl.tintColor = [UIColor iOS7darkGrayColor];
        [_segmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
}

@end
