//
//  BlackWhiteCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@interface BlackWhiteCell : SWTableViewCell


@property (strong, nonatomic) IBOutlet UILabel *labelPhone;
@property (strong, nonatomic) IBOutlet UILabel *labelBelongAddress;
@property (strong, nonatomic) IBOutlet UILabel *labelRemark;



-(void)setCellDetails:(NSDictionary *)item;
///设置左滑按钮
-(void)setLeftAndRightBtn;

@end
