//
//  AFNOManager.h
//  shangketong
//
//  Created by sungoin-zjp on 15-2-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface AFNOManager : AFHTTPRequestOperationManager
+ (instancetype)sharedGetClient;
+ (instancetype)sharedPostClient;
@end
