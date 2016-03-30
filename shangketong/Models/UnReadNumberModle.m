//
//  UnReadNumberModle.m
//  
//
//  Created by sungoin-zjp on 16/3/3.
//
//

#import "UnReadNumberModle.h"

@implementation UnReadNumberModle


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.number_message forKey:@"number_message"];
    [aCoder encodeObject:self.number_remind forKey:@"number_remind"];
    [aCoder encodeObject:self.number_inform forKey:@"number_inform"];
    [aCoder encodeObject:self.number_announcement forKey:@"number_announcement"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self.number_message = [aDecoder decodeObjectForKey:@"number_message"];
    self.number_remind = [aDecoder decodeObjectForKey:@"number_remind"];
    self.number_inform = [aDecoder decodeObjectForKey:@"number_inform"];
    self.number_announcement = [aDecoder decodeObjectForKey:@"number_announcement"];
    return self;
}


@end
