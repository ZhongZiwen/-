//
//  FollowRecordModel.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Record.h"

@implementation Record

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _altsArray = [[NSMutableArray alloc] initWithCapacity:0];
        _imageFilesArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)configMarkedTime {
    if ([self.created leftDayCount] == 0) {
        self.markedTime = @"今天";
    }else if ([self.created leftDayCount] == 1){
        self.markedTime = @"明天";
    }else if ([self.created leftDayCount] == -1){
        self.markedTime = @"昨天";
    }else{
        self.markedTime = [self.created stringYearMonthDayForLine];
    }
}

/***************发布动态或记录***************/
+ (instancetype)initRecordForSend {
    Record *record = [[Record alloc] init];
    record.recordImages = [[NSMutableArray alloc] initWithCapacity:0];
    record.recordContent = @"";
    return record;
}

- (NSDictionary*)toDoRecordParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    [params setObject:_recordId forKey:@"recordId"];
    [params setObject:_recordContent ? : @"快速记录" forKey:@"content"];
    // 定位
    if (_position) {
        [params setObject:_position forKey:@"position"];
        [params setObject:_latitude forKey:@"latitude"];
        [params setObject:_longitude forKey:@"longitude"];
    }
    if (_recordStaffIds && _recordStaffIds.length) {
        [params setObject:_recordStaffIds forKey:@"staffIds"];
    }
    if (_recordAudioSecond) {
        [params setObject:_recordAudioSecond forKey:@"second"];
    }
    // 关联客户
    if (_relationCustomerId) {
        [params setObject:_relationCustomerId forKey:@"customerId"];
    }
    
    return params;
}

#pragma mark - ALAsset
- (void)setSelectedAssetURLs:(NSMutableArray *)selectedAssetURLs {
    [selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addASelectedAssetUrl:obj];
    }];
}

- (void)addASelectedAssetUrl:(NSURL *)assetUrl {
    if (!_selectedAssetURLs) {
        _selectedAssetURLs = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    if (!_recordImages) {
        _recordImages = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    [_selectedAssetURLs addObject:assetUrl];
    
    NSMutableArray *recordImages = [self mutableArrayValueForKey:@"recordImages"];
    RecordImage *recordImage = [RecordImage recordImageWithAssetUrl:assetUrl];
    [recordImages addObject:recordImage];
}

- (void)deleteASelectedAssetUrl:(NSURL *)assetUrl {
    [self.selectedAssetURLs removeObject:assetUrl];
    NSMutableArray *recordImages = [self mutableArrayValueForKey:@"recordImages"];
    [recordImages enumerateObjectsUsingBlock:^(RecordImage *obj, NSUInteger idx, BOOL *stop) {
        if (obj.assetUrl == assetUrl) {
            [recordImages removeObject:obj];
            *stop = YES;
        }
    }];
}

- (void)deleteARecordImage:(RecordImage *)recordImage {
    NSMutableArray *recordImages = [self mutableArrayValueForKey:@"recordImages"];
    [recordImages removeObject:recordImage];
    if (recordImage.assetUrl) {
        [_selectedAssetURLs removeObject:recordImage.assetUrl];
    }
}
@end


@implementation RecordImage

+ (instancetype)recordImageWithImage:(UIImage *)image {
    RecordImage *recordImage = [[RecordImage alloc] init];
    recordImage.image = image;
    return recordImage;
}

+ (instancetype)recordImageWithAssetUrl:(NSURL *)assetUrl {
    RecordImage *recordImage = [[RecordImage alloc] init];
    recordImage.assetUrl = assetUrl;
    
    void (^selectAsset)(ALAsset*) = ^(ALAsset *asset) {
        if (asset) {
            UIImage *highQualityImage = [UIImage fullScreenImageALAsset:asset];
            UIImage *thumbnailImage = [UIImage imageWithCGImage:[asset thumbnail]];
            dispatch_async(dispatch_get_main_queue(), ^{
                recordImage.image = highQualityImage;
                recordImage.thumbnailImage = thumbnailImage;
            });
        }
    };
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    @weakify(assetsLibrary);
    [assetsLibrary assetForURL:assetUrl resultBlock:^(ALAsset *asset) {
        if (asset) {
            selectAsset(asset);
        }else {
            @strongify(assetsLibrary);
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stopG) {
                    if ([result.defaultRepresentation.url isEqual:assetUrl]) {
                        selectAsset(result);
                        *stop = YES;
                        *stopG = YES;
                    }
                }];
            } failureBlock:^(NSError *error) {
                [NSObject showHudTipStr:@"获取图片失败"];
            }];
        }
    } failureBlock:^(NSError *error) {
        [NSObject showHudTipStr:@"读取图片失败"];
    }];
    return recordImage;
}

+ (instancetype)recordImageWithAssetUrl:(NSURL *)assetUrl andImage:(UIImage *)image {
    RecordImage *recordImage = [[RecordImage alloc] init];
    recordImage.assetUrl = assetUrl;
    recordImage.image = image;
    recordImage.thumbnailImage = [image scaledToSize:CGSizeMake(kScaleFrom_iPhone5_Desgin(70), kScaleFrom_iPhone5_Desgin(70)) highQuality:YES];
    return recordImage;
}

@end