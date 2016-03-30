//
//  AfterServiceCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-15.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AfterServiceCell.h"
#import "LLCenterUtility.h"


@implementation AfterServiceCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(NSDictionary *)item anIndexPath:(NSIndexPath *)indexPath{
    /*
     serviceId(售后ID)
     serviceTitle(售后主题)
     serviceTypeId(售后类型Id)
     serviceTypeName(售后类型Name)
     serviceStatusId(售后状态Id)
     serviceStatusName(售后状态Name)
     serviceRemark(沟通状态)
     serviceCreateDate创建时间
     */
    
    NSString *title = @"";
    if ([item objectForKey:@"serviceTitle"]) {
        title = [item safeObjectForKey:@"serviceTitle"];
    }
    ///最多显示6个，多出部门用...表示
    if (title.length>6) {
        title = [NSString stringWithFormat:@"%@...",[title substringToIndex:6]];
    }
    self.labelTitle.text = [NSString stringWithFormat:@"业务主题: %@",title];
    
    
    NSString *statusName = @"";
    if ([item objectForKey:@"serviceStatusName"]) {
        statusName = [item safeObjectForKey:@"serviceStatusName"];
    }
    
    NSString *typeName = @"";
    if ([item objectForKey:@"serviceTypeName"]) {
        typeName = [item safeObjectForKey:@"serviceTypeName"];
    }
    
    NSString *createDate = @"";
    if ([item objectForKey:@"serviceCreateDate"]) {
        createDate = [item safeObjectForKey:@"serviceCreateDate"];
    }
    
    if (createDate && createDate.length > 10) {
        createDate = [createDate substringToIndex:10];
    }
    
    self.labelStatus.text = [NSString stringWithFormat:@"状态: %@",statusName];
    self.labelType.text = [NSString stringWithFormat:@"类型: %@",typeName];
    self.labelCreateDate.text = [NSString stringWithFormat:@"日期: %@",createDate];
    
    
    
    BOOL isChecked = FALSE;
    if ([item objectForKey:@"checked"]) {
        isChecked = [[item objectForKey:@"checked"] boolValue];
    }
    
    if (isChecked) {
        [self.btnCheckbox setBackgroundImage:[UIImage imageNamed:@"login_checkbox_filled.png"] forState:UIControlStateNormal];
    }else{
        [self.btnCheckbox setBackgroundImage:[UIImage imageNamed:@"login_checkbox_empty.png"] forState:UIControlStateNormal];
    }
    
    self.btnDetail.tag = indexPath.section;
    [self.btnDetail addTarget:self action:@selector(goEditDetailsView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnCheckbox.tag = indexPath.section;
    [self.btnCheckbox addTarget:self action:@selector(selectCheckbox:) forControlEvents:UIControlEventTouchUpInside];
}


///详情页面
- (void)goEditDetailsView:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (self.GotoEditDetailsViewBlock) {
        self.GotoEditDetailsViewBlock(tag);
    }
}


///选择框
- (void)selectCheckbox:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    if (self.NotifyCheckBoxBlock) {
        self.NotifyCheckBoxBlock(tag);
    }
}

///type 1 正常页面  2删除页面
-(void)setCellFrameWithType:(NSInteger)type{
//    self.labelTitle.frame = CGRectMake(15, 10, DEVICE_BOUNDS_WIDTH-30, 20);
//    self.btnDetail.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-40, 5, 25, 25);
    
    if (type ==1) {
        self.btnCheckbox.hidden = YES;
        self.btnDetail.hidden = NO;
        self.labelTitle.frame = CGRectMake(15, 10, DEVICE_BOUNDS_WIDTH-50, 20);
        self.btnDetail.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-40, 5, 21, 25.5);
    }else{
        self.btnCheckbox.hidden = NO;
        self.btnDetail.hidden = YES;
        self.btnCheckbox.frame = CGRectMake(15, 10, 20, 20);
        self.labelTitle.frame = CGRectMake(40, 10, DEVICE_BOUNDS_WIDTH-30, 20);
    }
    
    
    self.labelStatus.frame = CGRectMake(15, 40, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    self.labelType.frame = CGRectMake(self.labelStatus.frame.origin.x+self.labelStatus.frame.size.width+20, 40, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    
    self.labelCreateDate.frame = CGRectMake(15, 60, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
}


@end
