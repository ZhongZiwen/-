//
//  NameIndex.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NameIndex : NSObject

@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, assign) NSInteger sectionNum;
@property (nonatomic, assign) NSInteger originIndex;

- (NSString*)getFirstName;
- (NSString*)getLastName;
@end
