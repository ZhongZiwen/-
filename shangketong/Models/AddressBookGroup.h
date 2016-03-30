//
//  AddressBookGroup.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressBookGroup : NSObject<NSCoding>

@property (nonatomic, copy) NSString *groupName;            // 组名称
@property (nonatomic, strong) NSMutableArray *groupItems;   // 相同组名的数据

+ (AddressBookGroup*)initWithName:(NSString*)name;
- (AddressBookGroup*)initWithName:(NSString*)name;
@end
