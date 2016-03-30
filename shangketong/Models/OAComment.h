//
//  OAComment.h
//  shangketong
//
//  Created by sungoin-zbs on 16/1/14.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface OAComment : NSObject

@property (strong, nonatomic) NSNumber *id;
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) User *creator;
@property (strong, nonatomic) NSMutableArray *altsArray;
@end
