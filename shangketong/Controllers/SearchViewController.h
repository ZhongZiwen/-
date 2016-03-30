//
//  SearchViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SearchViewControllerType) {
    SearchViewControllerTypeActivity,       // 市场活动
    SearchViewControllerTypeLead,           // 销售线索
    SearchViewControllerTypeCustomer,       // 客户
    SearchViewControllerTypeContact,        // 联系人
    SearchViewControllerTypeOpportunity     // 销售机会
};

@interface SearchViewController : UIViewController

@property (assign, nonatomic) SearchViewControllerType searchType;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@end
