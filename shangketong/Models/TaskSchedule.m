//
//  TaskSchedule.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TaskSchedule.h"
#import "TaskScheduleGroup.h"
#import "Schedule.h"
#import "Task.h"

@interface TaskSchedule ()

@property (strong, nonatomic) TaskScheduleGroup *overGroup;
@property (strong, nonatomic) TaskScheduleGroup *todayGroup;
@property (strong, nonatomic) TaskScheduleGroup *tomorrerGroup;
@property (strong, nonatomic) TaskScheduleGroup *futureGroup;
@property (strong, nonatomic) TaskScheduleGroup *waitAcceptGroup;
@property (strong, nonatomic) TaskScheduleGroup *refuseGroup;
@property (strong, nonatomic) TaskScheduleGroup *finishedGroup;
@end

@implementation TaskSchedule

- (instancetype)init {
    self = [super init];
    if (self) {
        _waitArray = [[NSMutableArray alloc] initWithCapacity:0];
        _overGroup = [TaskScheduleGroup initWithGroupName:@"已过期"];
        _todayGroup = [TaskScheduleGroup initWithGroupName:@"今天"];
        _tomorrerGroup = [TaskScheduleGroup initWithGroupName:@"明天"];
        _futureGroup = [TaskScheduleGroup initWithGroupName:@"将来"];
        _waitAcceptGroup = [TaskScheduleGroup initWithGroupName:@"待接受"];
        _refuseGroup = [TaskScheduleGroup initWithGroupName:@"被拒绝"];
        
        [_waitArray addObject:_overGroup];
        [_waitArray addObject:_todayGroup];
        [_waitArray addObject:_tomorrerGroup];
        [_waitArray addObject:_futureGroup];
        [_waitArray addObject:_waitAcceptGroup];
        [_waitArray addObject:_refuseGroup];
        
        _finishedArray = [[NSMutableArray alloc] initWithCapacity:0];
        _finishedGroup = [TaskScheduleGroup initWithGroupName:@"完成"];
        [_finishedArray addObject:_finishedGroup];
    }
    return self;
}

- (void)configWithObj:(id)obj {
    // 日程
    if ([obj isKindOfClass:[Schedule class]]) {
        
        Schedule *schedule = obj;
        switch ([schedule.endDate daysBetweenCurrentDateAndDate]) {
            case -1: {  // 过去
                [_finishedGroup.array addObject:schedule];
            }
                break;
            case 0: {   // 今天
                [_todayGroup.array addObject:schedule];
            }
                break;
            case 1: {   // 明天
                [_tomorrerGroup.array addObject:schedule];
            }
                break;
            default:    // 将来
                [_futureGroup.array addObject:schedule];
                break;
        }

        return;
    }
    
    // 任务
    Task *task = obj;
    switch ([task.status integerValue]) {
        case 1: {   // 今天
            [_todayGroup.array addObject:task];
        }
            break;
        case 2: {   // 明天
            [_tomorrerGroup.array addObject:task];
        }
            break;
        case 3: {   // 将来
            [_futureGroup.array addObject:task];
        }
            break;
        case 4: {   // 已过期
            [_overGroup.array addObject:task];
        }
            break;
        case 5: {   // 待接受
            [_waitAcceptGroup.array addObject:task];
        }
            break;
        case 6: {   // 被拒绝
            [_refuseGroup.array addObject:task];
        }
            break;
        case 7: {   // 已完成
            [_finishedGroup.array addObject:task];
        }
            break;
        default:
            break;
    }
}

- (void)removeGroupForEmpityArray {
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
    for (TaskScheduleGroup *tempGroup in _waitArray) {
        if (!tempGroup.array.count) {
            [tempArray addObject:tempGroup];
        }
    }
    
    [_waitArray removeObjectsInArray:tempArray];
}
@end
