//
//  FilterConditionCCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "FilterConditionCCell.h"
#import "FilterCondition.h"

@interface FilterConditionCCell ()

@property (weak, nonatomic) UIView *bgView;
@property (weak, nonatomic) UILabel *title;
@property (weak, nonatomic) UILabel *detail;
@end

@implementation FilterConditionCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *backgroundView = [[UIView alloc] init];
        [backgroundView setHeight:44];
        backgroundView.backgroundColor = [UIColor colorWithHexString:@"0x7fd54f"];
        backgroundView.layer.cornerRadius = 5;
        backgroundView.clipsToBounds = YES;
        [self.contentView addSubview:backgroundView];
        _bgView = backgroundView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setY:4];
        [titleLabel setHeight:18];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [_bgView addSubview:titleLabel];
        _title = titleLabel;
        
        UILabel *detailLabel = [[UILabel alloc] init];
        [detailLabel setY:CGRectGetMaxY(titleLabel.frame)];
        [detailLabel setHeight:18];
        detailLabel.font = [UIFont systemFontOfSize:11];
        detailLabel.textColor = [UIColor whiteColor];
        detailLabel.textAlignment = NSTextAlignmentCenter;
        [_bgView addSubview:detailLabel];
        _detail = detailLabel;
    }
    return self;
}

- (void)configWithModel:(FilterCondition *)condition {
    CGFloat titleWidth = [condition.itemName getWidthWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    CGFloat detailWidth = [condition.valueName getWidthWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(MAXFLOAT, 20)];
    
    CGFloat maxWidth = MAX(titleWidth, detailWidth);
    [_bgView setWidth:maxWidth + 5];
    [_title setWidth:maxWidth];
    [_title setCenterX:(maxWidth + 5) / 2.0];
    [_detail setWidth:maxWidth];
    [_detail setCenterX:(maxWidth + 5) / 2.0];
    
    _title.text = condition.itemName;
    _detail.text = condition.valueName;
}
@end
