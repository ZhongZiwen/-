//
//  RingCellB.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-16.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RingCellB : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelRingName;
@property (strong, nonatomic) IBOutlet UILabel *labelDateType;
@property (strong, nonatomic) IBOutlet UILabel *labelDateRange;
@property (strong, nonatomic) IBOutlet UILabel *labelStartTime;
@property (strong, nonatomic) IBOutlet UILabel *labelEndTime;


@property (strong, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (strong, nonatomic) IBOutlet UIButton *btnDetail;

///type 1正常 2删除页面
-(void)setCellDetail:(NSDictionary *)item anIndexPath:(NSIndexPath *)indexPath andType:(NSInteger)type;
+(CGFloat)getCellHeight:(NSDictionary *)item;

///跳转到编辑页面
@property (nonatomic, copy) void (^GotoEditDetailsViewBlock)(NSInteger section);
///刷新选择框
@property (nonatomic, copy) void (^NotifyCheckBoxBlock)(NSInteger section);

@end
