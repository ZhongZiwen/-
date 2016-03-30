//
//  LastContactCell.h
//  shangketong
//  通讯录---最近联系人
//  Created by 蒋 on 15/7/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LastContactCellDelegate;

@interface LastContactCell : UITableViewCell
-(void)customCellForLastContact:(NSArray *)array;
@property (nonatomic, assign) id <LastContactCellDelegate> delegate;

@property (nonatomic, copy) void(^clickLatelyContactBlock)(NSInteger index);

@end

@protocol  LastContactCellDelegate <NSObject>
@required
- (void)pushToInfoAction:(NSInteger)userID;
@end
