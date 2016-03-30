//
//  DetailStaffModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailStaffModel.h"
#import "AddressBook.h"

@implementation DetailStaffModel

- (instancetype)initWithAddressBook:(AddressBook *)item {
    self = [super init];
    if (self) {
        self.id = item.id;
        self.staffLevel = @3;
        self.name = item.name;
        self.icon = item.icon;
    }
    return self;
}

+ (instancetype)initWithAddressBook:(AddressBook *)item {
    DetailStaffModel *staff = [[DetailStaffModel alloc] initWithAddressBook:item];
    return staff;
}
@end
