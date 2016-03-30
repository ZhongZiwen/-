//
//  WorkGroupRecordCellA.h
//  shangketong
//  活动记录等  无法对其做操作
//  Created by sungoin-zjp on 15-6-11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WorkGroupCell.h"

@interface WorkGroupRecordCellA : WorkGroupCell

@property (strong, nonatomic) IBOutlet UIButton *btnIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIButton *btnFrom;
@property (strong, nonatomic) IBOutlet UILabel *labelContent;


///填充详情
-(void)setContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;
///获取height
+(CGFloat)getCellContentHeight:(NSDictionary *)item;

@end
