//
//  WorkReportNewViewController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "XLFormViewController.h"

typedef NS_ENUM(NSInteger, WorkReportNewType) {
    WorkReportNewTypeNew,       // 新建(获取新建报告数据再组建表单)
    WorkReportNewTypeEdit,      // 编辑(通过上一级传的参数组建表单)
    WorkReportNewTypeSavePaper  // 草稿(先获取详情数据再组建表单)
};

@interface WRNewViewController : XLFormViewController

@property (nonatomic, assign) NSUInteger reportType;            // 报告类型：日报、周报、月报
@property (nonatomic, assign) WorkReportNewType newType;        // 新建报告来源类型：新建、编辑、草稿

@property (nonatomic, assign) NSInteger savePaperReportId;      // 获取草稿详情的id

@property (nonatomic, strong) NSDictionary *editDataSource;     // 编辑草稿的数据源
@property (nonatomic, copy) void(^refreshBlock)();              // 编辑或草稿提交返回刷新界面
@end
