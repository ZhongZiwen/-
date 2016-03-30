//
//  DepartGroupModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DepartGroupModel.h"
#import "pinyin.h"

@implementation DepartGroupModel

- (NSString*)getFirstName {
    
    NSString *firstName = [_name substringToIndex:1];
    
    if ([firstName canBeConvertedToEncoding:NSASCIIStringEncoding]) {   // 如果是英语
        
        // 判断是否为字母
        // 1、准备正则式
        NSString *regex = @"^[A-Za-z]*$"; // 只能是字母，不区分大小写
        // 2、拼接谓词
        NSPredicate *predicateRe1 = [NSPredicate predicateWithFormat:@"self matches %@", regex];
        // 3、匹配字符串
        BOOL resualt = [predicateRe1 evaluateWithObject:firstName];
        if (resualt) {
            return [firstName uppercaseString];
        }else {
            return @"#";
        }
    }else{  // 如果是非英语
        return [[NSString stringWithFormat:@"%c", pinyinFirstLetter([firstName characterAtIndex:0])] uppercaseString];
        //        return @"★";
    }
}

+ (NSString*)keyName {
    return @"pinyin";
}
@end
