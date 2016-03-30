//
//  FollowRecordModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "FileModel.h"
#import "AudioModel.h"
#import "RecordFrom.h"
#import "ValueIdModel.h"
#import "NameStringId.h"

@class RecordImage;

@interface Record : NSObject

@property (strong, nonatomic) NSNumber *id;             // 动态id
@property (strong, nonatomic) NSNumber *moduleType;     // 模块类型 1 OA(有员工转发) 2 CRM(有员工创建、系统创建)
@property (strong, nonatomic) NSNumber *type;           // 1员工创建、2员工转发、3系统创建
@property (strong, nonatomic) NSNumber *action;         // 业务类型下的操作类型：活动记录，文档上传，添加负责员工CrmTrendOperatorEnum.
@property (strong, nonatomic) NSNumber *system;         // 业务类型：工作圈，博客，市场活动 TrendBusinessEnum.
@property (strong, nonatomic) NSNumber *fileType;       // 0普通 1图片 2文档
@property (strong, nonatomic) NSNumber *commentCount;   // 评论数
@property (strong, nonatomic) NSNumber *canForward;     // 是否可以转发
@property (strong, nonatomic) NSNumber *isFeedUp;       // 是否被赞
@property (strong, nonatomic) NSNumber *feedUpCount;    // 被赞的个数
@property (strong, nonatomic) NSNumber *isfav;          // 是否已收藏

@property (copy, nonatomic) NSString *content;

@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) User *user;
@property (strong, nonatomic) RecordFrom *from;
@property (strong, nonatomic) NameStringId *activiyRecord;    // 活动记录类型 A001:记录 A002:电话 A003:拜访签到 A004:用户自定义

// 转发
@property (strong, nonatomic) Record *forward;

// 文档
@property (strong, nonatomic) FileModel *file;

// 音频
@property (strong, nonatomic) AudioModel *audio;

// 地理坐标
@property (copy, nonatomic) NSString *longitude;        // 经度
@property (copy, nonatomic) NSString *latitude;         // 维度
@property (copy, nonatomic) NSString *position;         // 地理位置

// @用户
@property (strong, nonatomic) NSMutableArray *altsArray;

// 图片
@property (strong, nonatomic) NSMutableArray *imageFilesArray;  // 图片列表

// 汇总时间
@property (copy, nonatomic) NSString *markedTime;
@property (assign, nonatomic) BOOL isShowMarkedTime;
- (void)configMarkedTime;


/******************发布记录、动态********************/
@property (copy, nonatomic) NSString *recordId;                 // 活动记录类型id
@property (strong, nonatomic) UIImage *simpleImage;
@property (strong, nonatomic) NSMutableArray *recordImages;     // 保存发布的图片
@property (strong, nonatomic) NSMutableArray *selectedAssetURLs;
@property (copy, nonatomic) NSString *recordContent;            // 发布的字符串
@property (copy, nonatomic) NSString *recordStaffIds;           // @人id
@property (copy, nonatomic) NSString *recordAudioFile;          // 语音文件名
@property (strong, nonatomic) NSNumber *recordAudioSecond;      // 语音秒数
@property (copy, nonatomic) NSString *relationCustomerName;     // 关联客户
@property (strong, nonatomic) NSNumber *relationCustomerId;     // 关联客户id

+ (instancetype)initRecordForSend;
- (NSDictionary*)toDoRecordParams;

- (void)addASelectedAssetUrl:(NSURL*)assetUrl;
- (void)deleteASelectedAssetUrl:(NSURL*)assetUrl;
- (void)deleteARecordImage:(RecordImage*)recordImage;
@end


@interface RecordImage : NSObject

@property (readwrite, strong, nonatomic) UIImage *image, *thumbnailImage;
@property (strong, nonatomic) NSURL *assetUrl;
@property (readwrite, copy, nonatomic) NSString *imageStr;

+ (instancetype)recordImageWithImage:(UIImage *)image;
+ (instancetype)recordImageWithAssetUrl:(NSURL*)assetUrl;
+ (instancetype)recordImageWithAssetUrl:(NSURL*)assetUrl andImage:(UIImage*)image;
@end
