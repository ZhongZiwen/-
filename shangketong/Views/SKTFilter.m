//
//  SKTFilter.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SKTFilter.h"
#import "SKTFilterValue.h"

@implementation SKTFilter

- (SKTFilter*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_id = [dict safeObjectForKey:@"id"];
        self.m_itemName = [dict objectForKey:@"itemName"];
        self.m_searchType = [[dict objectForKey:@"searchType"] integerValue];
        self.isCondition = NO;
        self.m_values = [[NSMutableArray alloc] initWithCapacity:0];
        if (_m_searchType == 3) {
            
        }else{
            for (NSDictionary *tempDict in [dict objectForKey:@"values"]) {
                SKTFilterValue *valueItem = [SKTFilterValue initWithDictionary:tempDict];
                [self.m_values addObject:valueItem];
            }
        }
    }
    return self;
}

+ (SKTFilter*)initWithDictionary:(NSDictionary *)dict {
    SKTFilter *filter = [[SKTFilter alloc] initWithDictionary:dict];
    return filter;
}

@end
