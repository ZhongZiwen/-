//
//  ColumnModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ColumnModel.h"
#import "ColumnSelectModel.h"

@implementation ColumnModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.selectArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    ColumnModel *column = [[self class] allocWithZone:zone];
    column.type = [_type copy];
    column.showWhenInit = [_showWhenInit copy];
    column.editAble = [_editAble copy];
    column.fullDate = [_fullDate copy];
    column.columnType = [_columnType copy];
    column.required = [_required copy];
    column.name = [_name copy];
    column.propertyName = [_propertyName copy];
    column.object = [_object copy];
    column.stringResult = [_stringResult copy];
    column.dateResult = [_dateResult copy];
    column.objectResult = [_objectResult copy];
    column.arrayResult = [_arrayResult copy];
    column.selectArray = [_selectArray copy];
    return column;
}

- (void)configResultWithDictionary:(NSDictionary *)tempDict {
    if ([_columnType isEqualToNumber:@1] || [_columnType isEqualToNumber:@2] || [_columnType isEqualToNumber:@3]) {
        if (tempDict[@"result"] != [NSNull null] && tempDict[@"result"]) {
            _stringResult = [NSString stringWithFormat:@"%@", tempDict[@"result"]];
        }
    }
    else if ([_columnType isEqualToNumber:@4] && tempDict[@"result"]) {
        if (tempDict[@"result"] != [NSNull null]) {
            _arrayResult = [[NSMutableArray alloc] initWithArray:tempDict[@"result"]];
        }
    }
    else if ([_columnType isEqualToNumber:@5] || [_columnType isEqualToNumber:@6] || [_columnType isEqualToNumber:@100]) {
        if (tempDict[@"result"] != [NSNull null] && tempDict[@"result"]) {
            _stringResult = [NSString stringWithFormat:@"%@", tempDict[@"result"]];
        }
    }
    else if ([_columnType isEqualToNumber:@7]) {
        if (tempDict[@"result"] != [NSNull null] && tempDict[@"result"]) {
            NSNumber *timeSince1970 = (NSNumber *)tempDict[@"result"];
            NSTimeInterval timeSince1970TimeInterval = timeSince1970.doubleValue/1000;
            _dateResult = [NSDate dateWithTimeIntervalSince1970:timeSince1970TimeInterval];
        }
    }
    else if ([_columnType isEqualToNumber:@10]) {
        if ([_type isEqualToNumber:@101] && tempDict[@"result"] != [NSNull null] && tempDict[@"result"]) {
            User *userObject = [NSObject objectOfClass:@"User" fromJSON:tempDict[@"result"]];
            _objectResult = userObject;
        }
        else if ([_type isEqualToNumber:@203] && tempDict[@"result"] != [NSNull null] && tempDict[@"result"]) {
            User *userObject = [NSObject objectOfClass:@"User" fromJSON:tempDict[@"result"]];
            _objectResult = userObject;
        }
        else if ([_type isEqualToNumber:@501] && tempDict[@"result"] != [NSNull null] && tempDict[@"result"]) {
            _stringResult = [NSString stringWithFormat:@"%@", tempDict[@"result"]];
        }
    }
}
@end
