//
//  NavDropView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TableViewCellType) {
    TableViewCellTypeDefault,           // 默认的cell类型
    TableViewCellTypeAssetsLabrary      // 用于访问相簿库
};

@interface NavDropView : UIView

@property (nonatomic, copy) void(^menuIndexClick)(NSInteger index);

- (id)initWithFrame:(CGRect)frame andType:(TableViewCellType)type andSource:(NSArray*)source andDefaultIndex:(NSInteger)index andController:(UIViewController*)controller;
@end
