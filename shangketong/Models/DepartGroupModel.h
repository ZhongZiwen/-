//
//  DepartGroupModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DepartGroupModel : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *pinyin;
@property (copy, nonatomic) NSString *icon;
@property (strong, nonatomic) NSNumber *hasChildren;
@property (strong, nonatomic) NSNumber *count;

- (NSString*)getFirstName;
+ (NSString*)keyName;
@end
