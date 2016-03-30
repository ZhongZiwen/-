//
//  FMDB_LLC_AUDIO.m
//  
//
//  Created by sungoin-zjp on 16/2/22.
//
//

#import "FMDB_LLC_AUDIO.h"
#import <FMDB.h>
#import "LLCAudioCache.h"

static NSString *const audioDataSourcePath = @"llc-audio-info-dataSource.sqlite";
static NSString *const table_llc_audio = @"llcaudiocache";      // 音频信息


@interface FMDB_LLC_AUDIO ()

@property (strong, nonatomic) FMDatabase *dataBase;

@end

@implementation FMDB_LLC_AUDIO

+ (NSString*)databaseFilePath {
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [filePath lastObject];
    NSLog(@"filePath = %@", filePath);
    NSString *dbFilePath = [documentPath stringByAppendingPathComponent:audioDataSourcePath];
    return dbFilePath;
}

+ (FMDB_LLC_AUDIO*)sharedFMDB_LLC_AUDIO_Manager {
    static dispatch_once_t onceToken;
    static FMDB_LLC_AUDIO *management = nil;
    dispatch_once(&onceToken, ^{
        management = [[FMDB_LLC_AUDIO alloc] init];
    });
    return management;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self creatDatabase];
    }
    return self;
}

// 创建数据库
- (void)creatDatabase {
    _dataBase = [FMDatabase databaseWithPath:[FMDB_LLC_AUDIO databaseFilePath]];
}

- (void)deleteFMDB {
    BOOL success;
    NSError *error;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // delete the old db.
    if ([fileManager fileExistsAtPath:[FMDB_LLC_AUDIO databaseFilePath]]) {
        [_dataBase close];
        _dataBase = nil;
        success = [fileManager removeItemAtPath:[FMDB_LLC_AUDIO databaseFilePath] error:&error];
        if (!success) {
            NSAssert1(0, @"Failed to delete old database file with message '%@'.", [error localizedDescription]);
        }
    }
}

// 创建表
- (void)creatAudioTable {
    
    // 先判断数据库是否存在，如果不存在，创建数据库
    if (!_dataBase) {
        [self creatDatabase];
    }
    
    // 判断数据库是否已经打开
    if (![_dataBase open]) {
        return;
    }
    
    // 为数据库设置缓存，提高查询效率
    [_dataBase setShouldCacheStatements:YES];
    
    // 判断数据库中是否已经存在这个表，如果不存在则创建该表
    // 创建table_skt_audio表
    if (![_dataBase tableExists:table_llc_audio]) {
        [_dataBase executeUpdate:[NSString stringWithFormat:@"create table %@(id integer primary key autoincrement,audio_url, integer, model blob)", table_llc_audio]];
    }
    
    [_dataBase close];
}


///存储音频信息
- (void)saveAudioData:(LLCAudioCache *)audioCache {
    
    // 判断数据库是否已经打开
    if (![_dataBase open]) {
        return;
    }
    
    //把模型通过归档转换成二进制数据
    NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:audioCache];
    
    //    [_dataBase executeUpdate:@"insert into login (user_id, model) values (?, ?)", user.id, modelData];
    
    // 向表中查询是否已经存在，如果没有，则插入
    FMResultSet *resultSet = [_dataBase executeQuery:@"select * from llcaudiocache where audio_url = ?",audioCache.audio_url];
    
    if ([resultSet next]) { // 存在
        [_dataBase executeUpdate:[NSString stringWithFormat:@"update %@ set model = ? where audio_url = ?", table_llc_audio], modelData, audioCache.audio_url];
        NSLog(@"更新音频缓存信息");
    }else { // 不存在，向表中插入一条数据
        [_dataBase executeUpdate:@"insert into llcaudiocache (audio_url, model) values (?, ?)", audioCache.audio_url, modelData];
        NSLog(@"初始化音频缓存信息");
    }
    
    [_dataBase close];
}

///根据url获取音频信息
- (LLCAudioCache*)getAudioData:(NSString *)audio_url {
    // 判断数据库是否已经打开
    if (![_dataBase open]) {
        return nil;
    }
    
    FMResultSet *resultSet = [_dataBase executeQuery:@"select * from llcaudiocache where audio_url = ?",audio_url];
    LLCAudioCache *cache = nil;
    while ([resultSet next]) {
        //取出模型数据
        NSData *data = [resultSet dataForColumn:@"model"];
        //反归档
        cache = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    [_dataBase close];
    return cache;
}


///音频文件是否存在
-(NSString *)isExistAudioCache:(NSString *)audio_url{
    // 判断数据库是否已经打开
    if (![_dataBase open]) {
        return @"";
    }
    FMResultSet *resultSet = [_dataBase executeQuery:@"select * from llcaudiocache where audio_url = ?",audio_url];
    
    if ([resultSet next]) {
        //存在 判断是否需要下载
        //取出模型数据
        NSData *data = [resultSet dataForColumn:@"model"];
        //反归档
        LLCAudioCache *cache = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return cache.audio_status;
    }
    
    return @"";
}

@end
