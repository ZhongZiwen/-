//
//  SKTConditionView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTConditionView.h"
#import "UIView+Common.h"
#import "NSString+Common.h"
#import "SKTCondition.h"

@interface SKTConditionView ()

@property (nonatomic, weak) UILabel *m_titleLabel;
@property (nonatomic, weak) UILabel *m_detailLabel;
@end

@implementation SKTConditionView

- (instancetype)initWithFrame:(CGRect)frame andConditionItem:(SKTCondition *)item {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0x7fd54f"];
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 24)];
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont systemFontOfSize:14];
        title.textAlignment = NSTextAlignmentCenter;
        title.text = item.m_itemName;
        [self addSubview:title];
        _m_titleLabel = title;
        
        UILabel *detail = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, CGRectGetWidth(self.bounds), 20)];
        detail.textColor = [UIColor whiteColor];
        detail.font = [UIFont systemFontOfSize:12];
        detail.textAlignment = NSTextAlignmentCenter;
        detail.text = item.m_name;
        [self addSubview:detail];
        _m_detailLabel = detail;
    }
    return self;
}

+ (instancetype)initWithFrame:(CGRect)frame andConditionItem:(SKTCondition *)item {
    SKTConditionView *conditionView = [[SKTConditionView alloc] initWithFrame:frame andConditionItem:item];
    return conditionView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
