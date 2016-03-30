//
//  DetailsRecordCell.h
//  shangketong
//  活动记录
//  Created by sungoin-zjp on 15-6-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DetailsRecordDelegate;

@interface DetailsRecordCell : UITableViewCell
@property (assign, nonatomic) id <DetailsRecordDelegate>delegate;
///日期  .06月18日
@property (strong, nonatomic) IBOutlet UIButton *btnDate;
///竖线1
@property (strong, nonatomic) IBOutlet UIImageView *imgLineTop;
///不同操作的图标
@property (strong, nonatomic) IBOutlet UIImageView *imgActionIcon;
///竖线2
@property (strong, nonatomic) IBOutlet UIImageView *imgLineBottom;
///内容
@property (strong, nonatomic) IBOutlet UILabel *labelContent;
///时间  10：26
@property (strong, nonatomic) IBOutlet UILabel *labelTime;

///抬头日期view
@property (weak, nonatomic) IBOutlet UIView *viewDate;



-(void)setCellDetails:(NSDictionary *)preItem  andCurItem:(NSDictionary *) item indexPath:(NSIndexPath *)indexPath;
///label添加点击手势
-(void)addClickEvent:(NSIndexPath *)indexPath;

+(CGFloat)getCellContentHeight:(NSDictionary *)preItem  andCurItem:(NSDictionary *) item indexPath:(NSIndexPath *)indexPath;;

@end


@protocol DetailsRecordDelegate<NSObject>
@required

///点击整个label事件
- (void)clickDetailRecordEvent:(NSInteger)index;

@end
