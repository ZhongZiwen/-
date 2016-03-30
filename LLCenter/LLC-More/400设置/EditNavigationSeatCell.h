//
//  EditNavigationSeatCell.h
//  lianluozhongxin
//   编辑导航最底层--座席列表cell
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditNavigationSeatCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelNo;
@property (strong, nonatomic) IBOutlet UILabel *labelWaitFlag;
@property (strong, nonatomic) IBOutlet UIButton *btnWait;
@property (strong, nonatomic) IBOutlet UILabel *labelStrategy;
@property (strong, nonatomic) IBOutlet UIButton *btnTime;
@property (strong, nonatomic) IBOutlet UIButton *btnArea;

/// 1  正常情况  2 编辑情况
-(void)setCellFrame:(NSInteger)flag;
-(void)setCellDetail:(NSDictionary *)item withIndexPath:(NSIndexPath *)indexPath;

///更改等待时间
@property (nonatomic, copy) void (^ChangeDurationBlock)(NSInteger index);
///更改地区策略
@property (nonatomic, copy) void (^ChangeAreaTypeBlock)(NSInteger index);
///更改时间策略
@property (nonatomic, copy) void (^ChangeTimeTypeBlock)(NSInteger index);

@end
