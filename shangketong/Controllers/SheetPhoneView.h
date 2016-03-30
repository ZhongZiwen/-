//
//  SheetPhoneView.h
//  shangketong
//
//  Created by 蒋 on 16/1/20.
//  Copyright (c) 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SheetPhoneView : UIView<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableViewSelect;
@property (nonatomic, strong) UIView *bgView;
//用来返回当前cell的下标
@property (nonatomic, copy) void(^BackIndexBlock)(NSInteger index);
//通过手势触发 从父试图将其移除
@property (nonatomic, copy) void(^RemoveViewBlock)();
//重写init方法
- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray *)array;

@end
