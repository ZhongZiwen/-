//
//  WorkReportNewItem.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WRNewItem.h"

@implementation WRNewItem

- (WRNewItem*)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.m_columnType = [dict[@"columnType"] integerValue];
        self.m_name = [dict safeObjectForKey:@"name"];
        self.m_propertyName = [dict safeObjectForKey:@"propertyName"];
        self.m_object = dict[@"object"];
        self.m_result = [dict safeObjectForKey:@"result"];
        self.m_required = [dict[@"required"] integerValue];
        self.m_fullDate = [dict[@"fullDate"] integerValue];
        if (_m_columnType == 3 || _m_columnType == 4) {
            self.m_selectArray = [[NSArray alloc] initWithArray:dict[@"select"]];
        }
    }
    return self;
}

+ (WRNewItem*)initWithDictionary:(NSDictionary *)dict {
    WRNewItem *item = [[WRNewItem alloc] initWithDictionary:dict];
    return item;
}
@end
