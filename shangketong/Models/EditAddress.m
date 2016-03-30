//
//  EditAddress.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EditAddress.h"
#import "AddressBook.h"

@implementation EditAddress

- (instancetype)initWithArray:(NSMutableArray *)array {
    self = [super init];
    if (self) {
        _sourceArray = array;
    }
    return self;
}

+ (instancetype)initWithArray:(NSMutableArray *)array {
    EditAddress *editAddress = [[EditAddress alloc] initWithArray:array];
    return editAddress;
}

#pragma mark - XLFormOptionObject
- (NSString*)formDisplayText {
    NSString *str;
    for (int i = 0; i < _sourceArray.count; i ++) {
        AddressBook *tempAddress = _sourceArray[i];
        if (i == 0) {
            str = tempAddress.name;
        }else {
            str = [NSString stringWithFormat:@"%@,%@", str, tempAddress.name];
        }
    }
    return str;
}

- (id)formValue {
    NSString *str;
    for (int i = 0; i < _sourceArray.count; i ++) {
        AddressBook *tempAddress = _sourceArray[i];
        if (i == 0) {
            str = [NSString stringWithFormat:@"%@", tempAddress.id];
        }else {
            str = [NSString stringWithFormat:@"%@,%@", str, tempAddress.id];
        }
    }
    return str;
}

@end
