//
//  ActivityModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityModel : NSObject<NSCoding, NSCopying>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *focus;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *pinyin;

+ (NSString*)keyName;
@end
