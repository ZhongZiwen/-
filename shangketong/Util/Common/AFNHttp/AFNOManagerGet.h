//
//  AFNOManagerGet.h
//  shangketong
//
//  Created by sungoin-zjp on 15-3-4.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
@interface AFNOManagerGet : AFHTTPRequestOperationManager
+ (instancetype)sharedClient;
@end
