//
//  AddOrEditDataDictionaryViewController.h
//  lianluozhongxin
//  新增、编辑数据字典
//  Created by sungoin-zjp on 15-10-19.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface AddOrEditDataDictionaryViewController : AppsBaseViewController

///新增 add  编辑 edit
@property(strong,nonatomic) NSString *actionType;
/// 客户来源 客户类型等待
@property(strong,nonatomic) NSString *actionName;
///sourceName  typeName
///typeName
///typeName stageName statusName
///statusName typeName
@property(strong,nonatomic) NSString *paramName;
///sourceId typeId
///typeId
///typeId stageId statusId
///statusId typeId
@property(strong,nonatomic) NSString *paramId;
@property(strong,nonatomic) NSString *urlName;
@property(strong,nonatomic) NSDictionary *detail;

///刷新字典列表
@property (nonatomic, copy) void (^NotifyDataDictionaryList)(void);


@end
