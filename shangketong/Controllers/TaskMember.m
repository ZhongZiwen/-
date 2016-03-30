//
//  TaskMember.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "TaskMember.h"

@implementation TaskMember

- (TaskMember*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        /*
        {
            createdBy =                 {
                icon = "<null>";
                name = "\U9648\U78ca";
                uid = 377;
            };
            date = 1437709980000;
            id = 334;
            mine = 0;
            name = "\U53d1\U90ae\U4ef6\U7ed9\U5ba2\U6237";
            owner =                 {
                icon = "<null>";
                name = "\U9648\U78ca";
                uid = 377;
            };
            priority = 0;
            status = 1;
        }
        */
        if ([dict objectForKey:@"name"]) {
            self.taskName = [dict safeObjectForKey:@"name"];
        } 
        if ([dict objectForKey:@"id"]) {
            self.taskID = [NSString stringWithFormat:@"%@", [dict safeObjectForKey:@"id"]];
        }
        if ([dict objectForKey:@"date"]) {
            self.taskDate = [NSString stringWithFormat:@"%@", [dict safeObjectForKey:@"date"]];
        }
        if ([dict objectForKey:@"from"]) {
            if ([[dict objectForKey:@"from"] objectForKey:@"belongName"]) {
                self.from_belongName = [[dict objectForKey:@"from"] safeObjectForKey:@"belongName"];
            }
            if ([[dict objectForKey:@"from"] objectForKey:@"name"]) {
                self.from_name = [[dict objectForKey:@"from"] safeObjectForKey:@"name"];
            }
        }
        
        if ([dict objectForKey:@"owner"] && [[dict objectForKey:@"owner"] objectForKey:@"name"]) {
            self.ownerName = [[dict objectForKey:@"owner"] safeObjectForKey:@"name"];
        }
        if ([dict objectForKey:@"status"]) {
            self.taskStatus = [[dict safeObjectForKey:@"status"] integerValue];
        }
        if ([dict objectForKey:@"priority"]) {
            self.taskPriority = [[dict safeObjectForKey:@"priority"] integerValue];
            NSLog(@"%ld", self.taskPriority);
        }
        if ([dict objectForKey:@"isMine"]) {
            self.taskMine = [[dict safeObjectForKey:@"isMine"] integerValue];
            NSLog(@"%ld", self.taskMine);
        }
        if ([dict objectForKey:@"createdBy"] && [[dict objectForKey:@"createdBy"] objectForKey:@"id"]) {
            self.creatByUID = [[[dict objectForKey:@"createdBy"] safeObjectForKey:@"id"] longLongValue];
        }
        if ([dict objectForKey:@"owner"] && [[dict objectForKey:@"owner"] objectForKey:@"id"]) {
            self.ownerByUID = [[[dict objectForKey:@"owner"] safeObjectForKey:@"id"] longLongValue];
        }
        
    }
    return self;
}

+ (TaskMember*)initWithDictionary:(NSDictionary *)dict {
    TaskMember *item = [[TaskMember alloc] initWithDictionary:dict];
    return item;
}
@end
