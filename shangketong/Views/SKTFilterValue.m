//
//  SKTFilterValue.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTFilterValue.h"
//#import "AddressSelectModel.h"
#import "AddressBook.h"

@implementation SKTFilterValue

- (SKTFilterValue*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict objectForKey:@"id"] == [NSNull null]) {
            self.m_id = @"-10";
            self.isSelected = YES;
        }else {
            self.m_id = [dict safeObjectForKey:@"id"] ;
            self.isSelected = NO;
        }
        self.m_name = [dict objectForKey:@"name"];
    }
    return self;
}

- (SKTFilterValue*)initWithModel:(AddressSelectModel *)item {
    self = [super init];
    if (self) {
//        self.m_id = item.m_id;
//        self.m_name = item.m_name;
//        self.m_icon = item.m_icon;
//        self.isSelected = NO;
    }
    return self;
}

+ (SKTFilterValue*)initWithDictionary:(NSDictionary *)dict {
    SKTFilterValue *filterValue = [[SKTFilterValue alloc] initWithDictionary:dict];
    return filterValue;
}

+ (SKTFilterValue*)initWithModel:(AddressSelectModel *)item {
    SKTFilterValue *filterValue = [[SKTFilterValue alloc] initWithModel:item];
    return filterValue;
}

+ (SKTFilterValue*)initWithAddressBookModel:(AddressBook *)item {
    SKTFilterValue *filterValue = [[SKTFilterValue alloc] initWithAddressBookModel:item];
    return filterValue;
}
- (SKTFilterValue*)initWithAddressBookModel:(AddressBook *)item {
    self = [super init];
    if (self) {
        self.m_id = [NSString stringWithFormat:@"%@",item.id];
        self.m_name = item.name;
        self.m_icon = item.icon;
//        self.isSelected = NO;
    }
    return self;
}
@end
