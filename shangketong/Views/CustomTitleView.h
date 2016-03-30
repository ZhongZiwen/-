//
//  CustomTitleView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeDefault,        // 默认的cell类型
    CellTypeAssetsLabrary,  // 用于访问相簿库
    CellTypeOnlyName
};

@interface CustomTitleView : UIView

@property (assign, nonatomic) CellType cellType;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (assign, nonatomic) NSInteger index;
@property (copy, nonatomic) NSString *defalutTitleString;
@property (weak, nonatomic) UIViewController *superViewController;
@property (assign, nonatomic) BOOL isShow;
@property (copy, nonatomic) void(^valueBlock) (NSInteger index);
@end
