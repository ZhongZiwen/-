//
//  TodayScheduleExpMenuCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-6-5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DataSourceType) {
    DataSourceTypeSchedule = 0, //日程
    DataSourceTypeTask = 1     //任务

};
typedef NS_ENUM(NSInteger, ActionType) {
    ActionTypeFinish = 1, //完成. 下一步
    ActionTypeLater = 2, //延时
    ActionTypeDelete = 3, //删除
    ActionTypeAccept = 4, //接受
    ActionTypeRefuse = 5, //拒绝
    ActionTypeQuit = 6, //退出
};
@protocol TodayScheduleMenuItemDelegate;

@interface TodayScheduleExpMenuCell : UITableViewCell

@property (assign, nonatomic) id <TodayScheduleMenuItemDelegate>delegate;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (strong, nonatomic) IBOutlet UIButton *btn1;
@property (strong, nonatomic) IBOutlet UILabel *label1;

@property (strong, nonatomic) IBOutlet UIButton *btn2;
@property (strong, nonatomic) IBOutlet UILabel *label2;

@property (strong, nonatomic) IBOutlet UIButton *btn3;
@property (strong, nonatomic) IBOutlet UILabel *label3;

@property (strong, nonatomic) IBOutlet UIButton *btn4;
@property (strong, nonatomic) IBOutlet UILabel *label4;

@property (nonatomic, assign) DataSourceType dataType;
@property (nonatomic, assign) ActionType actionType;
@property (nonatomic, assign) NSInteger dataId;


-(void)setCellFrame;
-(void)setCellContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;

@end


@protocol TodayScheduleMenuItemDelegate<NSObject>
@required

///点击菜单中按钮事件
- (void)clickMenuItemEvent:(NSInteger)tag withDataType:(DataSourceType)dataType withDataId:(NSInteger)dataId;

@end
