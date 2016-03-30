//
//  ExportAddress.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ExportAddress.h"
#import "AddressBook.h"

@implementation ExportAddress

- (instancetype)init {
    self = [super init];
    if (self) {
        _selectedArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithArray:(NSMutableArray *)array {
    self = [super init];
    if (self) {
        _selectedArray = array;
    }
    return self;
}

+ (instancetype)initWithArray:(NSMutableArray *)array {
    ExportAddress *exportAddress = [[ExportAddress alloc] initWithArray:array];
    return exportAddress;
}

#pragma mark - XLFormOptionObject
- (NSString*)formDisplayText {
    NSString *str;
    for (int i = 0; i < _selectedArray.count; i ++) {
        AddressBook *tempAddress = _selectedArray[i];
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
    for (int i = 0; i < _selectedArray.count; i ++) {
        AddressBook *tempAddress = _selectedArray[i];
        if (i == 0) {
            str = [NSString stringWithFormat:@"%@", tempAddress.id];
        }else {
            str = [NSString stringWithFormat:@"%@,%@", str, tempAddress.id];
        }
    }
    return str;
}

@end
