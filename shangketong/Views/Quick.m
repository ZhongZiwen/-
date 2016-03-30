//
//  Quick.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Quick.h"

@implementation Quick

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _imageString = [aDecoder decodeObjectForKey:@"imageString"];
        _titleString = [aDecoder decodeObjectForKey:@"titleString"];
        _isSelected = [aDecoder decodeObjectForKey:@"isSelected"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_imageString forKey:@"imageString"];
    [aCoder encodeObject:_titleString forKey:@"titleString"];
    [aCoder encodeObject:_isSelected forKey:@"isSelected"];
}
@end
