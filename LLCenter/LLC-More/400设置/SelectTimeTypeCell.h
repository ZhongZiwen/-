//
//  SelectTimeTypeCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TimeTypeModel;

@interface SelectTimeTypeCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIButton *btnWeek;
@property (strong, nonatomic) IBOutlet UIButton *btnStartTime;
@property (strong, nonatomic) IBOutlet UIButton *btnEndTime;
@property (strong, nonatomic) IBOutlet UIImageView *imgStartArrow;
@property (strong, nonatomic) IBOutlet UIImageView *imgEndArrow;


-(void)setCellDetails:(TimeTypeModel *)item andIndexPath:(NSIndexPath *)indexPath;


///星期事件
@property (nonatomic, copy) void (^CheckBoxBlock)(NSInteger index);
///开始时间
@property (nonatomic, copy) void (^StartTimeBlock)(NSInteger index);
///结束时间
@property (nonatomic, copy) void (^EndTimeBlock)(NSInteger index);

@end
