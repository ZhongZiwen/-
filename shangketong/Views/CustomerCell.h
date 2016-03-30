//
//  CustomerCell.h
//  shangketong
//  CRM - 客户
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
@interface CustomerCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UIView *viewSplit;
@property (strong, nonatomic) IBOutlet UILabel *labelMarkInfo;


@property (strong, nonatomic) IBOutlet UIImageView *imgSelectIcon;




-(void)setCellFrame;
-(void)setCellDetails:(NSDictionary *)item;
///设置左滑按钮
-(void)setLeftAndRightBtn:(NSDictionary *)item;
///设置选中图标
-(void)setSelectedIconShow:(NSString *)select;
@end
