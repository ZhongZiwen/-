//
//  LLCCustomerCell.h
//  lianluozhongxin
//  客户管理-cell
//  Created by sungoin-zjp on 15-7-2.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLCCustomerCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelCompany;
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;


-(void)setCellFrame;
-(void)setCellDetails:(NSDictionary *)item;

@end
