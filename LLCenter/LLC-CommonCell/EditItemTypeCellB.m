//
//  EditItemTypeCellB.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellB.h"
#import "EditItemModel.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"

@implementation EditItemTypeCellB

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.btnAction.frame = CGRectMake(kScreen_Width-50, 0, 50, 50);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setCellDetail:(EditItemModel *)model{
    CGSize sizeTitle = [CommonFunc getSizeOfContents:model.title Font:[UIFont systemFontOfSize:15.0] withWidth:2999 withHeight:20];
    self.labelTitle.frame = CGRectMake(10, 15, sizeTitle.width, 20);
    self.labelTitle.text = model.title;
    
    self.imgArrow.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-24, 16, 12, 18);
    self.btnContent.frame = CGRectMake(sizeTitle.width+10+10, 0, DEVICE_BOUNDS_WIDTH-sizeTitle.width-30-20, 50);
    
    if (([model.title isEqualToString:@"联系人类型:"] || [model.title isEqualToString:@"状态:"]|| [model.title isEqualToString:@"类型:"] || [model.title isEqualToString:@"阶段:"] || [model.title isEqualToString:@"付款方式:"]) && [model.content isEqualToString:@""]  ) {
        self.btnContent.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self.btnContent setTitleColor:COLOR_PLACEHOLDER forState:UIControlStateNormal];
        [self.btnContent setTitle:@"(必选)" forState:UIControlStateNormal];
    }else if (([model.title isEqualToString:@"彩铃:"] || [model.title isEqualToString:@"坐席提示音:"]) && [model.content isEqualToString:@""] ) {
        self.btnContent.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self.btnContent setTitleColor:COLOR_PLACEHOLDER forState:UIControlStateNormal];
        [self.btnContent setTitle:model.placeholder forState:UIControlStateNormal];
    }else{
        self.btnContent.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self.btnContent setTitleColor:COLOR_LIGHT_BLUE forState:UIControlStateNormal];
        
        
        NSString *content = model.content;
        
        if ([model.title isEqualToString:@"状态:"]|| [model.title isEqualToString:@"类型:"] || [model.title isEqualToString:@"阶段:"] ){
            if (content.length > 6) {
                content = [NSString stringWithFormat:@"%@...",[content substringToIndex:6]];
            }
        }
        
        
        if ([model.title isEqualToString:@"彩铃:"] || [model.title isEqualToString:@"炫铃选择:"] || [model.title isEqualToString:@"坐席提示音:"]){
            if (content.length > 8) {
                content = [NSString stringWithFormat:@"%@...",[content substringToIndex:8]];
            }
        }
        
        [self.btnContent setTitle:content forState:UIControlStateNormal];
        if ([content isEqualToString:@"(请选择)"]) {
            [self.btnContent setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
    }
    
    self.btnAction.hidden = YES;
    self.btnContent.enabled = YES;
    self.imgArrow.hidden = NO;
//    if ([model.keyStr isEqualToString:@""] && [model.keyType isEqualToString:@""]) {
//        self.btnContent.enabled = NO;
//        [self.btnContent setTitleColor:COLOR_PLACEHOLDER forState:UIControlStateNormal];
//    }
    
    ///不可编辑状态
    if (model.enabled && [model.enabled isEqualToString:@"no"]) {
        self.btnContent.enabled = NO;
        self.imgArrow.hidden = YES;
        
        if ([model.title isEqualToString:@"彩铃:"] && model.content.length > 0){
            self.btnAction.hidden = NO;
            [self.btnAction addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.btnContent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else{
            
            [self.btnContent setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        
    }
    
    [self.btnContent addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)selectType:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    if (self.SelectDataTypeBlock) {
        self.SelectDataTypeBlock(tag);
    }
}

///右边按钮事件
-(void)btnAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    if (self.SelectDataActionBlock) {
        self.SelectDataActionBlock(tag);
    }
}

@end
