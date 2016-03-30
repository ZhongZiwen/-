//
//  CellDataInfo.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-17.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CellDataInfo : NSObject {
    
}

@property (nonatomic,strong) NSDictionary *cellDataInfo;//单元内容
@property (nonatomic,strong) id extra;//其他内容
@property bool expandable;//单元是否可扩张
@property bool expanded;//单元是否处于扩张状态

//初始化函数
- (id)initWithCellDataInfo:(NSDictionary*)_cInfo;

- (id)initWithCellDataInfo:(NSDictionary*)_cInfo expandable:(bool)_expandale;

- (id)initWithCellDataInfo:(NSDictionary*)_cInfo expandable:(bool)_expandale expanded:(bool)_expanded;

@end
