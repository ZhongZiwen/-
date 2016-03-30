//
//  PlanCell.h
//  shangketong
//  日程页面列表cell
//  Created by sungoin-zjp on 15-5-30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>

@protocol PlanDelegate;

@interface PlanCell : SWTableViewCell

@property (assign, nonatomic) id <PlanDelegate>delegate;

@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UIButton *btnSelect;
@property (strong, nonatomic) IBOutlet UILabel *labelTitleA;
@property (strong, nonatomic) IBOutlet UILabel *labelTitleB;
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;


///设置当前item的详情
-(void)setCellDetails:(NSDictionary *)item indexPath:(NSIndexPath *)index;
///设置左滑按钮
-(void)setLeftAndRightBtn:(NSInteger )typeCell withItemDetail:(NSDictionary *)item;

@end

@protocol PlanDelegate<NSObject>
@required

///点击选择框事件
- (void)clickSelectBtnEvent:(long long)planID;
@end
