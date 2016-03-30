//
//  DepartGroupGroupModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepartGroupGroupModel : NSObject

@property (copy, nonatomic) NSString *groupName;
@property (strong, nonatomic) NSMutableArray *groupArray;

+ (DepartGroupGroupModel*)initWithGroupName:(NSString*)name;
- (DepartGroupGroupModel*)initWithGroupName:(NSString*)name;
@end
