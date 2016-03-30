//
//  EditNavigationSeatCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditNavigationSeatCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"




@implementation EditNavigationSeatCell

- (void)awakeFromNib {
    // Initialization code
   [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(NSDictionary *)item withIndexPath:(NSIndexPath *)indexPath{
    /*
     CALLORDER = 232538000;
     COMPANYID = "5a198602-a925-4a2c-a4fa-cd2aa4b63a20";
     LSH = 232537900;
     NUM = 1;
     SITID = "896a2b42-a9a7-49b5-8837-84a0b498cd1f";
     SITNAME = "\U738b\U8bdb\U9b54";
     SITNO = 2003;
     SITPHONE = 13918374623;
     USERID = "75c6507a-0682-45e5-af9c-c1ca87cc0189";
     WAITDURATION = 25;
     */
    NSString *sitNo = @"";
    if ([item objectForKey:@"SITNO"]) {
        sitNo = [item safeObjectForKey:@"SITNO"];
    }
    
    NSString *waitDuration = @"";
    if ([item objectForKey:@"WAITDURATION"]) {
        waitDuration = [item safeObjectForKey:@"WAITDURATION"];
    }
    
    self.labelNo.text = sitNo;
    [self.btnWait setTitle:waitDuration forState:UIControlStateNormal];
    
    ///等待时长
    self.btnWait.tag = indexPath.row;
    [self.btnWait addTarget:self action:@selector(changeDuration:) forControlEvents:UIControlEventTouchUpInside];
    
    ///地区
    self.btnArea.tag = indexPath.row;
    [self.btnArea addTarget:self action:@selector(changeAreaType:) forControlEvents:UIControlEventTouchUpInside];
    
    ///时间
    self.btnTime.tag = indexPath.row;
    [self.btnTime addTarget:self action:@selector(changeTimeType:) forControlEvents:UIControlEventTouchUpInside];
    
}


///更改等待时间
-(void)changeDuration:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.ChangeDurationBlock) {
        self.ChangeDurationBlock(btn.tag);
    }
}


///地区
-(void)changeAreaType:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.ChangeAreaTypeBlock) {
        self.ChangeAreaTypeBlock(btn.tag);
    }
}


///地区
-(void)changeTimeType:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.ChangeTimeTypeBlock) {
        self.ChangeTimeTypeBlock(btn.tag);
    }
}


/// 1  正常情况  2 编辑情况
-(void)setCellFrame:(NSInteger)flag{
    NSInteger width = (DEVICE_BOUNDS_WIDTH-320)/3;
    
    self.btnWait.frame = CGRectMake(120, 0, 50+width, 50);
    self.labelStrategy.frame = CGRectMake(175+width, 15, 45, 20);
    self.btnTime.frame = CGRectMake(210+width, 0, 50+width, 50);
    self.btnArea.frame = CGRectMake(260+width*2, 0, 50+width, 50);
    
    
    if (flag == 1) {
        
    }else if (flag == 2){
        self.labelNo.frame = [CommonFunc setViewFrameOffset:self.labelNo.frame byX:-40 byY:0 ByWidth:0 byHeight:0];
        self.labelWaitFlag.frame = [CommonFunc setViewFrameOffset:self.labelWaitFlag.frame byX:-40 byY:0 ByWidth:0 byHeight:0];
        self.btnWait.frame = [CommonFunc setViewFrameOffset:self.btnWait.frame byX:-40 byY:0 ByWidth:0 byHeight:0];
        self.labelStrategy.frame = [CommonFunc setViewFrameOffset:self.labelStrategy.frame byX:-40 byY:0 ByWidth:0 byHeight:0];
        self.btnTime.frame = [CommonFunc setViewFrameOffset:self.btnTime.frame byX:-40 byY:0 ByWidth:0 byHeight:0];
        self.btnArea.frame = [CommonFunc setViewFrameOffset:self.btnArea.frame byX:-60 byY:0 ByWidth:0 byHeight:0];
    }
    
}

@end
