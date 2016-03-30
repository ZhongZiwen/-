//
//  AreaTypeCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AreaTypeCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

-(void)setCellDetails:(NSDictionary *)item andIndexPath:(NSIndexPath *)indexPath;


///选择框事件
@property (nonatomic, copy) void (^CheckBoxBlock)(NSInteger index);

@end
