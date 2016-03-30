//
//  MRTitleImagesCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/1.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DataSourceType) {
    DataSourceTypeDictionary,   // 数据源为字典类型
    DataSourceTypeArray         // 数据源为数组类型
};

@interface MRTitleImagesCell : UITableViewCell

+ (CGFloat)cellHeightWithType:(DataSourceType)type andMembersCount:(NSInteger)count;
- (void)configWithTitleString:(NSString*)titleStr andObject:(id)obj andType:(DataSourceType)type;
@end
