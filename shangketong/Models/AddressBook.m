//
//  AddressBook.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddressBook.h"
#import "pinyin.h"
#import "User.h"
#import "FilterValue.h"
#import "DetailStaffModel.h"

@implementation AddressBook

- (instancetype)copyWithZone:(NSZone *)zone {
    AddressBook *item = [[self class] allocWithZone:zone];
    item.id = [_id copy];
    item.name = [_name copy];
    item.pinyin = [_pinyin copy];
    item.icon = [_icon copy];
    item.position = [_position copy];
    item.depart = [_depart copy];
    item.focused = [_focused copy];
    item.mobile = [_mobile copy];
    item.phone = [_phone copy];
    item.extensionNumber = [_extensionNumber copy];
    item.status = [_status copy];
    return item;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.pinyin forKey:@"pinyin"];
    [aCoder encodeObject:self.icon forKey:@"icon"];
    [aCoder encodeObject:self.position forKey:@"position"];
    [aCoder encodeObject:self.depart forKey:@"depart"];
    [aCoder encodeObject:self.focused forKey:@"focused"];
    [aCoder encodeObject:self.mobile forKey:@"mobile"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeObject:self.extensionNumber forKey:@"extensionNumber"];
    [aCoder encodeObject:self.status forKey:@"status"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.pinyin = [aDecoder decodeObjectForKey:@"pinyin"];
        self.icon = [aDecoder decodeObjectForKey:@"icon"];
        self.position = [aDecoder decodeObjectForKey:@"position"];
        self.depart = [aDecoder decodeObjectForKey:@"depart"];
        self.focused = [aDecoder decodeObjectForKey:@"focused"];
        self.mobile = [aDecoder decodeObjectForKey:@"mobile"];
        self.phone = [aDecoder decodeObjectForKey:@"phone"];
        self.extensionNumber = [aDecoder decodeObjectForKey:@"extensionNumber"];
        self.status = [aDecoder decodeObjectForKey:@"status"];
    }
    return self;
}

- (AddressBook*)initWithUser:(User *)user {
    self = [super init];
    if (self) {
        _id = user.id;
        _name = user.name;
        _icon = user.icon;
        _pinyin = user.pinyin;
    }
    return self;
}

+ (AddressBook*)initWithUser:(User *)user {
    AddressBook *item = [[AddressBook alloc] initWithUser:user];
    return item;
}

- (AddressBook*)initWithFilter:(FilterValue *)item {
    self = [super init];
    if (self) {
        _id = @([item.id integerValue]);
        _name = item.name;
        _icon = item.icon;
    }
    return self;
}

+ (AddressBook*)initWithFilter:(FilterValue *)item {
    AddressBook *addressBook = [[AddressBook alloc] initWithFilter:item];
    return addressBook;
}

- (AddressBook*)initWithStaff:(DetailStaffModel *)item {
    self = [super init];
    if (self) {
        _id = item.id;
        _name = item.name;
        _icon = item.icon;
    }
    return self;
}

+ (AddressBook*)initWithStaff:(DetailStaffModel *)item {
    AddressBook *addressBook = [[AddressBook alloc] initWithStaff:item];
    return addressBook;
}

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
    return @"name";
}

#pragma mark - XLFormOptionObject
-(NSString *)formDisplayText {
    return self.name;
}

-(id)formValue {
    return self.id;
}

@end
