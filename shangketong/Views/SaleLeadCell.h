//
//  SaleLeadCell.h
//  shangketong
//  CRM-销售线索
//  Created by sungoin-zjp on 15-6-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
@interface SaleLeadCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UIImageView *imgNew;
@property (strong, nonatomic) IBOutlet UILabel *labelCompanyName;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIView *viewSplit;
@property (strong, nonatomic) IBOutlet UILabel *labelMarkInfo;




-(void)setCellDetails:(NSDictionary *)item;
///设置左滑按钮
-(void)setLeftAndRightBtn:(NSDictionary *)item;

@end
