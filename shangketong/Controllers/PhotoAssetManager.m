//
//  PhotoAssetManager.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "PhotoAssetManager.h"
#import "PhotoAssetModel.h"

@implementation PhotoAssetManager

//+ (PhotoAssetManager*)sharedAssetManager {
//    static dispatch_once_t onceToken;
//    static PhotoAssetManager *assetManager = nil;
//    dispatch_once(&onceToken, ^{
//        assetManager = [[PhotoAssetManager alloc] init];
//    });
//    return assetManager;
//}

- (id)init {
    self = [super init];
    if (self) {
        // 申明ALAssetsLibrary，用于枚举图片库
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        _selectedArray = [[NSMutableArray alloc] initWithCapacity:0];
        _assetsGroupArray = [[NSMutableArray alloc] initWithCapacity:0];
        _groupPhotoaArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)getALAssetsGroupAllComplete:(void (^)())complete {
    
    void (^assetGroupEnumErrorBlock) (NSError*) = ^(NSError *error) {
        NSString *msgError = @"Cannot access asset library groups";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msgError delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    };
    
    if (_assetsGroupArray.count) {
        [_assetsGroupArray removeAllObjects];
    }
    
    void (^enumerateAssetGroupsBlock) (ALAssetsGroup*, BOOL*) = ^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group) {    // 照片库中的每一个相簿执行这个块一次，并在遍历完所有的相簿后再执行一次。
            // 获取相簿包含的照片和视频总数
            NSUInteger numAssets = [group numberOfAssets];
            
            // 相簿名称
            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            
            // 相簿的url（url用来访问group相簿，以免再次枚举此方法）
            NSURL *groupUrl = [group valueForProperty:ALAssetsGroupPropertyURL];
            
            // 相簿的海报图片（相簿的封面照片）
            UIImage *posterImage = [UIImage imageWithCGImage:group.posterImage];
            
            // 设置筛选器，筛选照片、视频和所有资源
            // 筛选相簿的照片
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            NSUInteger groupPhotos = [group numberOfAssets];
            
            // 筛选相簿的视频
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            NSUInteger groupVideos = [group numberOfAssets];
            
            NSDictionary *groupDict = @{kGroupLabelText: groupName,
                                        kGroupPhotoCounts: [NSString stringWithFormat:@"%d", groupPhotos],
                                        kGroupPosterImage: posterImage,
                                        kGroupURL: groupUrl};
            [_assetsGroupArray insertObject:groupDict atIndex:0];
        }else { // 在最后一个执行时，没有传入ALAssetsGroup实例，说明枚举已结束，对数据源做后期处理（在这里我们把相簿列表数据源传给导航栏下拉菜单）
            complete();
        }
    };
    
    // 调用枚举照片库的方法
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:enumerateAssetGroupsBlock failureBlock:assetGroupEnumErrorBlock];
}

- (void)retrieveAssetGroupByURL:(NSURL *)url andGroupName:(NSString *)groupName complete:(void (^)())complete {
    
    void (^retrieveGroupBlock)(ALAssetsGroup*) = ^(ALAssetsGroup *group) {
        if (group) {
            
            [_groupPhotoaArray removeAllObjects];
            
            // 筛选器，筛选照片、视频和所有资源
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            // 通过筛选器，获取group的照片总数
            NSUInteger groupPhotos = [group numberOfAssets];
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result != nil) {
                    
                    /*
                     //获取资源图片的高清图
                     [representation fullResolutionImage];
                     //获取资源图片的全屏图
                     [representation fullScreenImage];
                     ALAssetRepresentation *rep = [result defaultRepresentation];
                     
                     UIImage *img = [UIImage imageWithCGImage:[rep fullScreenImage]];
                     */
                    PhotoAssetModel *model = [PhotoAssetModel initWithALAsset:result andGroupName:groupName andIndex:index];
                    
                    for (PhotoAssetModel *tempModel in _selectedArray) {
                        if ([groupName isEqualToString:tempModel.groupName]) {
                            if (index == tempModel.index) {
                                model.isSelected = YES;
                            }
                        }
                    }
                    [_groupPhotoaArray addObject:model];
                }
                
                if (index == (groupPhotos - 1)) {
                    complete();
                }
            }];
            
        }else {
            NSLog(@"Error. Can't find group!");
        }
    };
    
    void (^handleAssetGroupErrorBlock)(NSError*) = ^(NSError *error) {
        NSString *errMsg = @"Error accessing group";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:errMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
    };
    
    [_assetsLibrary groupForURL:url resultBlock:retrieveGroupBlock failureBlock:handleAssetGroupErrorBlock];
}

- (void)deleteObjFromSelectedArrayWith:(PhotoAssetModel *)model {
    NSUInteger indexTag = -1;
    for (int i = 0; i < _selectedArray.count; i ++) {
        PhotoAssetModel *tempModel = _selectedArray[i];
        if ([model.groupName isEqualToString:tempModel.groupName]) {
            if (model.index == tempModel.index) {
                indexTag = i;
            }
        }
    }
    
    if (indexTag != -1) {
        [_selectedArray removeObjectAtIndex:indexTag];
    }
}

- (void)deleteObjFromGroupPhotoArrayWith:(PhotoAssetModel *)model {
    for (PhotoAssetModel *tempModel in _groupPhotoaArray) {
        if (model.index == tempModel.index) {
            tempModel.isSelected = NO;
        }
    }
}

- (void)selecteCameraPhoto {
    PhotoAssetModel *photoModel = _groupPhotoaArray.lastObject;
    photoModel.isSelected = YES;
    [_selectedArray addObject:photoModel];
}

@end
