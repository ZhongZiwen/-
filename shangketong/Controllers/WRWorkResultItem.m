//
//  WRWorkResultItem.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WRWorkResultItem.h"

@implementation WRWorkResultItem

- (WRWorkResultItem*)initWithTitleString:(NSString *)titleStr andValueString:(NSString *)valueStr {
    CGRect frame = CGRectMake(0, 0, kScreen_Width/3.0, 70);
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.bounds), 15)];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, CGRectGetWidth(self.bounds), 15)];
        valueLabel.font = [UIFont systemFontOfSize:14];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.text = valueStr;
        [self addSubview:valueLabel];
        
        if ([titleStr isEqualToString:@"赢单金额"] || [titleStr isEqualToString:@"新建合同金额"] || [titleStr isEqualToString:@"新增回款金额"]) {
            titleLabel.text = [NSString stringWithFormat:@"%@(元)", titleStr];
            valueLabel.textColor = [UIColor redColor];
        }else {
            titleLabel.text = titleStr;
            valueLabel.textColor = [UIColor colorWithRed:(CGFloat)70/255.0 green:(CGFloat)154/255.0 blue:(CGFloat)234/255.0 alpha:1.0];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tap {
    if (self.itemClickBlock) {
        self.itemClickBlock(self.tag);
    }
}

+ (WRWorkResultItem*)initWithTitleString:(NSString *)titleStr andValueString:(NSString *)valueStr {
    WRWorkResultItem *item = [[WRWorkResultItem alloc] initWithTitleString:titleStr andValueString:valueStr];
    return item;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
