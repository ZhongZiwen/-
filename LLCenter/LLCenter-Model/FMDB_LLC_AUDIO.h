//
//  FMDB_LLC_AUDIO.h
//  
//
//  Created by sungoin-zjp on 16/2/22.
//
//

#import <Foundation/Foundation.h>
@class LLCAudioCache;

@interface FMDB_LLC_AUDIO : NSObject

+ (NSString*)databaseFilePath;
+ (FMDB_LLC_AUDIO*)sharedFMDB_LLC_AUDIO_Manager;
// 删除数据库
- (void)deleteFMDB;

///存储音频
- (void)creatAudioTable;
- (void)saveAudioData:(LLCAudioCache *)audioCache;
- (LLCAudioCache*)getAudioData:(NSString *)audio_url ;
-(NSString *)isExistAudioCache:(NSString *)audio_url;

@end
