//
//  TaskSchedule.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskSchedule : NSObject

@property (strong, nonatomic) NSMutableArray *finishedArray;
@property (strong, nonatomic) NSMutableArray *waitArray;

- (void)configWithObj:(id)obj;
- (void)removeGroupForEmpityArray;
@end
