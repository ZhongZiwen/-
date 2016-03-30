 //
//  Select_Table_View.h
//  Select_TableView
//  右上角item 点击事件UI
//  Created by 蒋 on 15/9/24.
//  Copyright (c) 2015年 蒋. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Select_Table_View : UIView<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableViewSelect;
@property (nonatomic, strong) UIView *bgView;
//用来返回当前cell的下标
@property (nonatomic, copy) void(^BackIndexBlock)(NSInteger index);
//通过手势触发 从父试图将其移除
@property (nonatomic, copy) void(^RemoveViewBlock)();
//重写init方法
- (instancetype)initWithFrame:(CGRect)frame dataArray:(NSArray *)array;
@end
