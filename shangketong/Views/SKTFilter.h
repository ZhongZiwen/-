//
//  SKTFilter.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKTFilter : NSObject

@property (nonatomic, copy) NSString *m_id;
@property (nonatomic, copy) NSString *m_itemName;
@property (nonatomic, assign) NSInteger m_searchType;
@property (nonatomic, assign) BOOL isCondition;
@property (nonatomic, strong) NSMutableArray *m_values;

+ (SKTFilter*)initWithDictionary:(NSDictionary*)dict;
- (SKTFilter*)initWithDictionary:(NSDictionary*)dict;
@end
