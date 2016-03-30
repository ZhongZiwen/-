//
//  ScheduleType.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLForm.h>

@interface ScheduleType : NSObject<XLFormOptionObject>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *color;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *title;
@end
