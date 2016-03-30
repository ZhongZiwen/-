//
//  LLCSaleOpportunityCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLCSaleOpportunityCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UILabel *labelSaleStatus;
@property (strong, nonatomic) IBOutlet UILabel *labelSaleType;
@property (strong, nonatomic) IBOutlet UILabel *labelSaleStage;
@property (strong, nonatomic) IBOutlet UILabel *labelSaleCreateDate;

@property (strong, nonatomic) IBOutlet UIButton *btnDetail;

@property (strong, nonatomic) IBOutlet UIButton *btnCheckBox;



-(void)setCellDetail:(NSDictionary *)item anIndexPath:(NSIndexPath *)indexPath;
///type 1 正常页面  2删除页面
-(void)setCellFrameWithType:(NSInteger)type;

///跳转到详情页面
@property (nonatomic, copy) void (^GotoEditDetailsViewBlock)(NSInteger section);
///刷新选择框
@property (nonatomic, copy) void (^NotifyCheckBoxBlock)(NSInteger section);

@end
