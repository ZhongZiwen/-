//
//  NSDictionary+safeObjectForKey.h
//  shangketong
//
//  Created by sungoin-zjp on 15-7-20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (safeObjectForKey)
-(NSString *)safeObjectForKey:(id)key;
-(BOOL)isObjectNil;
@end
