//
//  tetsTableViewCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-7-16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "tetsTableViewCell.h"

@implementation tetsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/*
 * UNKNOWN(0, "未定义类型"), //未定义类型 TEXT(1, "文本类型", CompareType.textTypes),
 * //文本类型 TEXTAREA(2," 文本区域类型"), //文本区域类型 SELECT(3,"单选类型",
 * CompareType.selectTypes), //单选类型 CHECKBOX(4,"多选类型",
 * CompareType.selectTypes), //多选类型 INT(5,"整数类型",
 * CompareType.numberTypes), //整数类型 FLOAT(6,"浮点类型",
 * CompareType.numberTypes), //浮点类型 DATE(7,"日期类型",
 * CompareType.numberTypes), //日期类型 LINE(8,"--"), //分割线类型
 * NUMBER(9,"自动编号",CompareType.textTypes), //自动编号-文本类型
 * OBJECT(10,"对象类型",CompareType.selectTypes); //对象类型
 */


/*
 
 type 0 系统生成  1 发布  2 转发
 fileType  0 不存在  1图片  2附件
 file  附件
 imageFiles 图片
 
 forward字段存在则存在转发  不存在显示@“该动态已经被删除”
 
 */

@end
