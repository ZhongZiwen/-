//
//  WorkReportWorkResultCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WRWorkResultCell.h"
#import <POP.h>
#import "UIView+Common.h"
#import "WRWorkResultItem.h"
#import "WRWorkResultHUD.h"
#import "AFNHttp.h"

#define kButtonTag 3464352

NSString *const XLFormRowDescriptorTypeWorkReportActivityRecords = @"XLFormRowDescriptorTypeWorkReportActivityRecords";

@interface WRWorkResultCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *lineView;     // 标识线
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation WRWorkResultCell

+ (void)load {
    [XLFormViewController.cellClassesForRowDescriptorTypes setObject:[WRWorkResultCell class] forKey:XLFormRowDescriptorTypeWorkReportActivityRecords];
}

- (void)configure {
    [super configure];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *array = @[@"业绩", @"行为", @"新增"];
    int i = 0;
    for (NSString *str in array) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(i*(kScreen_Width/3.0), 0, kScreen_Width/3.0, 44);
        button.tag = kButtonTag + i;
        [button addLineUp:NO andDown:YES];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:str forState:UIControlStateNormal];
        [button addTarget:self action:@selector(titleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        i ++;
    }
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.scrollView];

    // 获取报告类型
    NSUInteger reportType = [self.rowDescriptor.value unsignedIntegerValue];

    WRWorkResultHUD *progressHUD = [[WRWorkResultHUD alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 70 + 44)];
    [self.contentView addSubview:progressHUD];
    
    NSArray *reportTypeArray = @[@"dayReport", @"weekReport", @"monthReport"];
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:reportTypeArray[reportType] forKey:@"type"];
    
    // 发起请求
    [progressHUD startAnimationWith:@"销售数据生成中，请稍候..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [AFNHttp post:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,REPORT_WORK_RESULT] params:params success:^(id responseObj) {
            NSLog(@"销售数据汇总: %@", responseObj);
            [progressHUD stopAnimationWith:nil];
            if (responseObj && ![[responseObj objectForKey:@"status"] integerValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 业绩
                    NSArray *performaceArray = [NSArray arrayWithArray:responseObj[@"activityRecords"][@"performace"]];
                    if (performaceArray.count > 3) {
                      performaceArray = [performaceArray subarrayWithRange:NSMakeRange(0, 3)];
                    }
                    for (int i = 0; i < performaceArray.count; i ++) {
                        NSDictionary *tempDict = (responseObj[@"activityRecords"][@"performace"])[i];
                        WRWorkResultItem *item = [WRWorkResultItem initWithTitleString:tempDict[@"name"] andValueString:tempDict[@"value"]];
                        [item setX:(kScreen_Width / 3.0) * i];
                        item.tag = 100 + i;
                        item.itemClickBlock = ^(NSInteger tag) {
                            
                        };
                        [_scrollView addSubview:item];
                    }
                    
                    // 行为
                    for (int i = 0; i < [(responseObj[@"activityRecords"][@"behavior"]) count]; i ++) {
                        NSDictionary *tempDict = (responseObj[@"activityRecords"][@"behavior"])[i];
                        WRWorkResultItem *item = [WRWorkResultItem initWithTitleString:tempDict[@"name"] andValueString:tempDict[@"value"]];
                        [item setX:kScreen_Width + (kScreen_Width / 3.0) * i];
                        item.tag = 200 + i;
                        item.itemClickBlock = ^(NSInteger tag) {
                            
                        };
                        [_scrollView addSubview:item];
                    }
                    
                    // 新增
                    for (int i = 0; i < [(responseObj[@"activityRecords"][@"newAction"]) count]; i ++) {
                        NSDictionary *tempDict = (responseObj[@"activityRecords"][@"newAction"])[i];
                        WRWorkResultItem *item = [WRWorkResultItem initWithTitleString:tempDict[@"name"] andValueString:tempDict[@"value"]];
                        [item setX:2 * kScreen_Width + (kScreen_Width / 3.0) * i];
                        item.tag = 300 + i;
                        item.itemClickBlock = ^(NSInteger tag) {
                            
                        };
                        [_scrollView addSubview:item];
                    }
                });
            }
            
        } failure:^(NSError *error) {
            [progressHUD stopAnimationWith:@"销售数据生成失败！"];
            
        }];
    });
}

- (void)update {
    [super update];
    
    
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 44.0f + 70.0f;
}

#pragma mark - Private Method
- (void)popAnimationWithIndex:(NSInteger)index {
    
    POPSpringAnimation *animation = [POPSpringAnimation animation];
    animation.property = [POPAnimatableProperty propertyWithName:kPOPViewCenter];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake((2*index+1)*(kScreen_Width/6.0), 43)];    // 中心点的移动
    animation.springBounciness = 10.0;
    animation.springSpeed = 50.0;
    [_lineView pop_addAnimation:animation forKey:@"center"];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    
    NSInteger pageIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    [self popAnimationWithIndex:pageIndex];
}

#pragma mark - event response
- (void)titleButtonPress:(UIButton*)sender {
    
    [self popAnimationWithIndex:sender.tag - kButtonTag];
    
    [_scrollView setContentOffset:CGPointMake(kScreen_Width*(sender.tag - kButtonTag), 0) animated:YES];
}

#pragma mark - setters and getters
- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 2)];
        [_lineView setCenter:CGPointMake((kScreen_Width/6.0), 43)];
        _lineView.backgroundColor = [UIColor colorWithRed:(CGFloat)70/255.0 green:(CGFloat)154/255.0 blue:(CGFloat)234/255.0 alpha:1.0];
    }
    return _lineView;
}

- (UIScrollView*)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, kScreen_Width, 70)];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        [_scrollView setContentSize:CGSizeMake(kScreen_Width * 3, 70)];
    }
    return _scrollView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
