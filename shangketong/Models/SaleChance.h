//
//  SaleChance.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaleChance : NSObject<NSCoding, NSCopying>

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber *focus;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *customerName;
@property (copy, nonatomic) NSString *money;
@property (copy, nonatomic) NSString *ownerName;

+ (NSString*)keyName;
@end
