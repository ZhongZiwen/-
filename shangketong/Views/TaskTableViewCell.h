//
//  TaskTableViewCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SWTableViewCell.h"

@protocol TaskTableViewCellDelegate;

@class TaskMember;

@interface TaskTableViewCell : SWTableViewCell

+ (CGFloat)cellHeight;
- (void)configWithItem:(TaskMember*)item;
@property (nonatomic, assign) id<TaskTableViewCellDelegate> delegate;
@end

@protocol  TaskTableViewCellDelegate<NSObject>

- (void)getTasksIDForChange:(long long)taskID;

@end
