//
//  RingCellA.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RingCellA : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelRingName;
@property (strong, nonatomic) IBOutlet UILabel *labelDateType;
@property (strong, nonatomic) IBOutlet UILabel *labelDateRange;
@property (strong, nonatomic) IBOutlet UILabel *labelStartTime;
@property (strong, nonatomic) IBOutlet UILabel *labelEndTime;


@property (strong, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (strong, nonatomic) IBOutlet UIButton *btnDetail;


-(void)setCellDetail:(NSDictionary *)item anIndexPath:(NSIndexPath *)indexPath;
///type 1 正常页面  2删除页面
-(void)setCellFrameWithType:(NSInteger)type;
+(CGFloat)getCellHeight;
///跳转到编辑页面
@property (nonatomic, copy) void (^GotoEditDetailsViewBlock)(NSInteger section);
///刷新选择框
@property (nonatomic, copy) void (^NotifyCheckBoxBlock)(NSInteger section);

@end
