//
//  TaskMember.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskMember : NSObject

@property (nonatomic, copy) NSString *taskName;
@property (nonatomic, copy) NSString *taskID;
@property (nonatomic, copy) NSString *taskDate;
@property (nonatomic, copy) NSString *from_belongName;  // 来自哪里
@property (nonatomic, copy) NSString *from_name;    // 客户的具体名称
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, assign) NSInteger taskPriority;
@property (nonatomic, assign) NSInteger taskMine;
@property (nonatomic, assign) long long creatByUID; //创建人id
@property (nonatomic, assign) long long ownerByUID; //责任人id
// 1 2 3 4 5 6 7
//今天 明天 将来 已过期 待接收 被拒绝 已完成
@property (nonatomic, assign) NSInteger taskStatus;

- (TaskMember*)initWithDictionary:(NSDictionary*)dict;
+ (TaskMember*)initWithDictionary:(NSDictionary*)dict;
@end
