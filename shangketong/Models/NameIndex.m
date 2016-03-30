//
//  NameIndex.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "NameIndex.h"
#import "pinyin.h"

@implementation NameIndex

- (NSString*)getFirstName
{
    if ([_firstName canBeConvertedToEncoding:NSASCIIStringEncoding]) {   // 如果是英语
        return _firstName;
    }else{  // 如果是非英语
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([_firstName characterAtIndex:0])];
    }
}

- (NSString*)getLastName
{
    if ([_lastName canBeConvertedToEncoding:NSASCIIStringEncoding]) {   // 如果是英语
        return _lastName;
    }else{  // 如果是非英语
        return [NSString stringWithFormat:@"%c", pinyinFirstLetter([_lastName characterAtIndex:0])];
    }
}

@end
