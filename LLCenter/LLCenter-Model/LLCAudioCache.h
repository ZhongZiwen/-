//
//  LLCAudioCache.h
//  
//
//  Created by sungoin-zjp on 16/2/22.
//
//

#import <Foundation/Foundation.h>

@interface LLCAudioCache :NSObject<NSCoding>

@property (copy, nonatomic) NSString *audio_url;
@property (copy, nonatomic) NSData *audio_data;
@property (copy, nonatomic) NSString *audio_name;
@property (copy, nonatomic) NSString *audio_path;
@property (copy, nonatomic) NSString *audio_status;

@end
