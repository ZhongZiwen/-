//
//  LLCSaleOpportunityCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-13.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "LLCSaleOpportunityCell.h"
#import "LLCenterUtility.h"

@implementation LLCSaleOpportunityCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetail:(NSDictionary *)item anIndexPath:(NSIndexPath *)indexPath{
    /*
     saleTitle(销售主题)
     saleStatus(销售状态)
     saleType(销售类型)
     saleStage(销售阶段)
     saleCreateDate(销售机会创建时间)
     
     saleCreateDate = "2015-11-23 21:07:27";
     saleId = "10cf326f-3726-4239-9196-3bd3b15deab4";
     saleStageId = "fc28fff0-1851-4b11-9551-aac3e89bb559";
     saleStageName = "有购买需求";
     saleStatusId = "23f997b0-a259-475b-b9e0-e56d03e27140";
     saleStatusName = "跟踪";
     saleTitle = guihggyyyyhhh;
     saleTypeId = "d7f8d3a3-3e4f-4688-9152-7018de9e2634";
     saleTypeName = "新单";
     
     */
    
    NSString *saleTitle = @"";
    if ([item objectForKey:@"saleTitle"]) {
        saleTitle = [item safeObjectForKey:@"saleTitle"];
    }
    ///最多显示6个，多出部门用...表示
    if (saleTitle.length>6) {
        saleTitle = [NSString stringWithFormat:@"%@...",[saleTitle substringToIndex:6]];
    }
    
    self.labelTitle.text = [NSString stringWithFormat:@"业务主题: %@",saleTitle];
    
   
    NSString *saleType = @"";
    if ([item objectForKey:@"saleTypeName"]) {
        saleType = [item safeObjectForKey:@"saleTypeName"];
    }
    NSString *saleStage = @"";
    if ([item objectForKey:@"saleStageName"]) {
        saleStage = [item safeObjectForKey:@"saleStageName"];
    }
    NSString *saleCreateDate = @"";
    if ([item objectForKey:@"saleCreateDate"]) {
        saleCreateDate = [item safeObjectForKey:@"saleCreateDate"];
    }
    
    if (saleCreateDate && saleCreateDate.length > 10) {
        saleCreateDate = [saleCreateDate substringToIndex:10];
    }
    
    NSString *saleStatus = @"";
    if ([item objectForKey:@"saleStatusName"]) {
        saleStatus = [item safeObjectForKey:@"saleStatusName"];
    }
    
    self.labelSaleType.text = [NSString stringWithFormat:@"类型: %@",saleType];
    self.labelSaleStage.text = [NSString stringWithFormat:@"阶段: %@",saleStage];
    self.labelSaleCreateDate.text = [NSString stringWithFormat:@"日期: %@",saleCreateDate];
    self.labelSaleStatus.text = [NSString stringWithFormat:@"状态: %@",saleStatus];
    
    
    
    BOOL isChecked = FALSE;
    if ([item objectForKey:@"checked"]) {
        isChecked = [[item objectForKey:@"checked"] boolValue];
    }
    
    if (isChecked) {
        [self.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"login_checkbox_filled.png"] forState:UIControlStateNormal];
    }else{
        [self.btnCheckBox setBackgroundImage:[UIImage imageNamed:@"login_checkbox_empty.png"] forState:UIControlStateNormal];
    }
    
    self.btnDetail.tag = indexPath.section;
    [self.btnDetail addTarget:self action:@selector(goEditDetailsView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.btnCheckBox.tag = indexPath.section;
    [self.btnCheckBox addTarget:self action:@selector(selectCheckbox:) forControlEvents:UIControlEventTouchUpInside];
}


///详情页面
- (void)goEditDetailsView:(id)sender {
    NSLog(@"goDetailsView--->");
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
        self.btnCheckBox.hidden = YES;
        self.btnDetail.hidden = NO;
        self.labelTitle.frame = CGRectMake(15, 10, DEVICE_BOUNDS_WIDTH-50, 20);
        self.btnDetail.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-40, 5, 21, 25.5);
    }else{
        self.btnCheckBox.hidden = NO;
        self.btnDetail.hidden = YES;
        self.btnCheckBox.frame = CGRectMake(15, 10, 20, 20);
        self.labelTitle.frame = CGRectMake(40, 10, DEVICE_BOUNDS_WIDTH-30, 20);
    }
    
    self.labelSaleStatus.frame = CGRectMake(15, 40, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    self.labelSaleStage.frame = CGRectMake(self.labelSaleStatus.frame.origin.x+self.labelSaleStatus.frame.size.width+20, 40, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    
    self.labelSaleType.frame = CGRectMake(15, 60, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
    self.labelSaleCreateDate.frame = CGRectMake(self.labelSaleType.frame.origin.x+self.labelSaleType.frame.size.width+20, 60, (DEVICE_BOUNDS_WIDTH-30-20)/2+10, 20);
    
    
   
    
    
}



/*
 self.labelSaleType.frame = CGRectMake(15, 40, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
 self.labelSaleStage.frame = CGRectMake(self.labelSaleType.frame.origin.x+self.labelSaleType.frame.size.width+20, 40, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
 
 self.labelSaleCreateDate.frame = CGRectMake(15, 60, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
 self.labelSaleStatus.frame = CGRectMake(self.labelSaleCreateDate.frame.origin.x+self.labelSaleCreateDate.frame.size.width+20, 60, (DEVICE_BOUNDS_WIDTH-30-20)/2, 20);
 */

@end
