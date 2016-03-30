//
//  DataDictionaryDetailCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DataDictionaryDetailCell.h"
#import "LLCenterUtility.h"

@implementation DataDictionaryDetailCell

- (void)awakeFromNib {
    // Initialization code
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.btnRemove.frame = CGRectMake(DEVICE_BOUNDS_WIDTH-65, 0, 65, 50);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSDictionary *)item{
    ///详情
    NSString *name = [item safeObjectForKey:@"name"];
    ///最多显示6个，多出用...表示
    if (name.length>6) {
        name = [NSString stringWithFormat:@"%@...",[name substringToIndex:6]];
    }
    
    self.labelTitle.text = name;

    self.btnOption.hidden = NO;
    NSInteger defaultSet = 0;
    if ([item objectForKey:@"default"]) {
        defaultSet = [[item safeObjectForKey:@"default"] integerValue];
    }
    
    self.labelTitle.frame = CGRectMake(55, 15, 200, 20);
    
    self.labelTitle.textColor = [UIColor blackColor];
    NSString *imgName = @"";
    ///设置不同的图标  减号
    if (defaultSet == 1) {
        NSLog(@"显示移除图标----->");
        imgName = @"icon_item_remove.png";
    }else if (defaultSet == 0) {
        imgName = @"icon_item_insert.png";
    }else if (defaultSet == -1) {
        NSLog(@"隐藏移除图标----->");
        imgName = @"";
        self.btnOption.hidden = YES;
        self.labelTitle.frame = CGRectMake(15, 15, 200, 20);
        self.labelTitle.textColor = [UIColor grayColor];
    }
    
    [self.btnOption setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    
    if (defaultSet == 1) {
        [self.btnOption removeTarget:self action:@selector(insertDictinaryToDefault) forControlEvents:UIControlEventTouchUpInside];
        [self.btnOption addTarget:self action:@selector(showRemoveBtn) forControlEvents:UIControlEventTouchUpInside];
        
        [self.btnRemove addTarget:self action:@selector(removeDictinaryToDefault) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self.btnOption removeTarget:self action:@selector(showRemoveBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.btnOption addTarget:self action:@selector(insertDictinaryToDefault) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

///设置为默认
-(void)insertDictinaryToDefault{
    if (self.InsertDefaultDictionaryBlock) {
        self.InsertDefaultDictionaryBlock();
    }
}


///显示移除按钮
-(void)showRemoveBtn{
    if (self.ShowRemoveBtnBlock) {
        self.ShowRemoveBtnBlock();
    }
}

///移除默认
-(void)removeDictinaryToDefault{
    if (self.RemoveDefaultDictionaryBlock) {
        self.RemoveDefaultDictionaryBlock();
    }
}


///设置左滑按钮
-(void)setLeftAndRightBtn{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:LLC_COLOR_SEARCHBAR_BG title:@"编辑"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor redColor] title:@"删除"];
   
    self.leftUtilityButtons = nil;
    [self setRightUtilityButtons:rightUtilityButtons WithButtonWidth:65.0];
}



@end
