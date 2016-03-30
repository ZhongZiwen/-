//
//  AddOrDelContactController.h
//  shangketong
//  
//  Created by 蒋 on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddOrDelContactController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableViewAddOrDel;
@property (nonatomic, strong) NSArray *contactModelArray;
@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *type; //区分组是否存在  0存在 1不存在
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, strong) NSString *groupType;
@property (nonatomic, copy) void(^BlackContactArray)(NSArray *array);
@property (nonatomic, copy) void(^BlackGroupNewNameBlock)(NSString *string);

@end
