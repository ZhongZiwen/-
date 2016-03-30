//
//  SectionHeaderView.h
//  Test
//
//  Created by 钟必胜 on 15/10/1.
//  Copyright (c) 2015年 wendell. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CRMDetail;

typedef NS_ENUM(NSInteger, SectionHeaderViewType) {
    SectionHeaderViewTypeActivity,
    SectionHeaderViewTypeLead,
    SectionHeaderViewTypeCustomer,
    SectionHeaderViewTypeContact,
    SectionHeaderViewTypeOpportunity
};

@interface SectionHeaderView : UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (assign, nonatomic) SectionHeaderViewType type;

@property (strong, nonatomic) NSMutableArray *titlesArray;
@property (strong, nonatomic) NSMutableArray *valuesArray;

@property (copy, nonatomic) void(^saleLeadBlock)(void);     // 销售线索
@property (copy, nonatomic) void(^saleOpportunityBlock)(void);  // 销售机会
@property (copy, nonatomic) void(^contacterBlock)(void);    // 联系人
@property (copy, nonatomic) void(^customerBlock)(void);     // 客户
@property (copy, nonatomic) void(^taskScheduleBlock)(void); // 日程任务
@property (copy, nonatomic) void(^approvalBlock)(void);     // 审批
@property (copy, nonatomic) void(^productBlock)(void);      // 产品
@property (copy, nonatomic) void(^fileBlock)(void);         // 文档

- (void)configDataSourceWithDetailItem:(CRMDetail*)item;
@end
