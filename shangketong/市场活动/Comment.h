//
//  Comment.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/19.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Comment : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) User *creator;
@property (strong, nonatomic) NSMutableArray *altsArray;
@end
