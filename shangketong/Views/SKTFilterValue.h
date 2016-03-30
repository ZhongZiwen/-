//
//  SKTFilterValue.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AddressSelectModel, AddressBook;

@interface SKTFilterValue : NSObject

@property (nonatomic, copy) NSString *m_id;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_icon;

+ (SKTFilterValue*)initWithDictionary:(NSDictionary*)dict;
- (SKTFilterValue*)initWithDictionary:(NSDictionary*)dict;

+ (SKTFilterValue*)initWithModel:(AddressSelectModel*)item;
- (SKTFilterValue*)initWithModel:(AddressSelectModel*)item;
+ (SKTFilterValue*)initWithAddressBookModel:(AddressBook *)item;
- (SKTFilterValue*)initWithAddressBookModel:(AddressBook *)item;
@end
