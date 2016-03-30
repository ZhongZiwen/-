//
//  AddressBookTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressBook, DepartGroupModel;

@interface AddressBookTableViewCell : UITableViewCell

@property (copy, nonatomic) void(^phoneBtnClickedBlock)(void);

+ (CGFloat)cellHeight;

// 通讯录中显示公司部门和群组
- (void)configWithImageOfName:(NSString*)name title:(NSString*)title;
// 显示公司部门或群组
- (void)configDepartGroupWithModel:(DepartGroupModel*)model type:(NSInteger)type;
// 通讯录中显示联系人
- (void)configWithModel:(AddressBook*)model;
// 显示不带打电话的联系人
- (void)configWithoutButtonWithModel:(AddressBook*)model;
@end
