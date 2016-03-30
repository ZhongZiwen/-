//
//  LLCAudioCache.m
//  
//
//  Created by sungoin-zjp on 16/2/22.
//
//

#import "LLCAudioCache.h"

@implementation LLCAudioCache

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.audio_url forKey:@"audio_url"];
    [aCoder encodeObject:self.audio_name forKey:@"audio_name"];
    [aCoder encodeObject:self.audio_path forKey:@"audio_path"];
    [aCoder encodeObject:self.audio_status forKey:@"audio_status"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self.audio_url = [aDecoder decodeObjectForKey:@"audio_url"];
    self.audio_name = [aDecoder decodeObjectForKey:@"audio_name"];
    self.audio_path = [aDecoder decodeObjectForKey:@"audio_path"];
    self.audio_status = [aDecoder decodeObjectForKey:@"audio_status"];
    return self;
}

@end
