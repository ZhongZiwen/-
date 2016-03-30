//
//  MoreCustomerCell.h
//  lianluozhongxin
//  客户管理-更多列表
//  Created by sungoin-zjp on 15-7-6.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GoToCustomerDetailsDelegate;

@interface MoreCustomerCell : UITableViewCell
@property (assign, nonatomic) id <GoToCustomerDetailsDelegate>delegate;

@property (strong, nonatomic) IBOutlet UILabel *labelTitleName;
@property (strong, nonatomic) IBOutlet UITableView *tableview;

@property (strong, nonatomic) IBOutlet UIImageView *imgLine;



@property(strong,nonatomic) NSArray *arrayCustomers;

-(void)setCellDetails:(NSArray *)array indexPath:(NSIndexPath *)indexPath;

@end

@protocol GoToCustomerDetailsDelegate<NSObject>
@required
///跳转到详情页面
- (void)gotoCustomerDetails:(NSDictionary *)item;
@end
