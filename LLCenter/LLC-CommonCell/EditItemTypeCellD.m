//
//  EditItemTypeCellD.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "EditItemTypeCellD.h"
#import "EditItemModel.h"

@implementation EditItemTypeCellD

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetail:(EditItemModel *)model andLeftTitle:(NSString *)leftTitle andRightTitle:(NSString *)rightTitle{
    self.labelTitle.text = model.title;
    ///设置图标显示
    [self setImgShow:[model.content integerValue]];

    [self.btnComp setTitle:leftTitle forState:UIControlStateNormal];
    [self.btnComp addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
    self.btnComp.tag = 0;
    
    [self.btnPersonal setTitle:rightTitle forState:UIControlStateNormal];
    [self.btnPersonal addTarget:self action:@selector(selectType:) forControlEvents:UIControlEventTouchUpInside];
    self.btnPersonal.tag = 1;
    
}

-(void)selectType:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    [self setImgShow:tag];
    if (self.SelectCustomerTypeBlock) {
        self.SelectCustomerTypeBlock(tag);
    }
}


-(void)setImgShow:(NSInteger)type{
    
    
    NSString *compImg = @"choose_select.png";
    NSString *custImg = @"choose_select.png";
    ///公司客户
    if (type == 0) {
        compImg = @"choose_selected.png";
        custImg = @"choose_select.png";
    }else{
        compImg = @"choose_select.png";
        custImg = @"choose_selected.png";
    }
    self.imgComp.image = [UIImage imageNamed:compImg];
    self.imgPersonal.image = [UIImage imageNamed:custImg];
}

@end
