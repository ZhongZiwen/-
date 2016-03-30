//
//  CustomerSearchCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CustomerSearchCell.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "CommonModuleFuntion.h"

@implementation CustomerSearchCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setCellDetails:(NSDictionary *)item index:(NSIndexPath *)indexPath{
    ///name
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    self.labelName.text = name;
    self.labelName.frame = CGRectMake(20,5 , kScreen_Width-70, 20);
    
    
    self.imgIcon.frame = CGRectMake(20, 30, 13, 13);
    ///highSeaStatus
    NSInteger highSeaStatus = -1;
    if ([item objectForKey:@"highSeaStatus"]) {
        highSeaStatus = [[item safeObjectForKey:@"highSeaStatus"] integerValue];
    }
    NSString *statusName = [CommonModuleFuntion getHighSeaStatusName:highSeaStatus];
    ///获取到对应的name 和 对应的图标
    self.labelStatus.text = statusName;
#warning 获取对应的图标
    self.imgIcon.image = [UIImage imageNamed:@"UMS_add_friend_on.png"];
    
    
    CGSize sizeStatusName = [CommonFuntion getSizeOfContents:statusName Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-120 withHeight:20];
    self.labelStatus.frame = CGRectMake(40, 26, sizeStatusName.width, 20);
    
    
    ///split
    self.imgSplit.frame = CGRectMake(self.labelStatus.frame.origin.x+sizeStatusName.width+2, 30, 1, 10);
    
    ///expireTime
    NSString *markInfo = @"";
    if ([item objectForKey:@"expireTime"]) {
        
        if ([[item safeObjectForKey:@"expireTime"] longLongValue] <= 0 ) {
            self.labelMarkInfo.hidden = YES;
            self.imgSplit.hidden = YES;
        }else{
            self.labelMarkInfo.hidden = NO;
            self.imgSplit.hidden = NO;
            /// 转换几天后回收
            long long expireTime = 0;
            if ([item objectForKey:@"expireTime"]) {
                expireTime = [[item safeObjectForKey:@"expireTime"] longLongValue];
            }
            
            NSDate *dateExpireTime = [[NSDate alloc]initWithTimeIntervalSince1970:expireTime/1000.0];
            ///时差
            NSTimeInterval tInterval = [dateExpireTime timeIntervalSinceDate:[NSDate date]];
            
            if (tInterval <= 0) {
                self.labelMarkInfo.hidden = YES;
                self.imgSplit.hidden = YES;
            }else{
                if (tInterval < HOUR_OF_SECONDS) {
                    markInfo = [NSString stringWithFormat:@"%i分钟后回收",(int)tInterval/60];
                }else  if (tInterval < DAY_OF_SECONDS) {
                    markInfo = [NSString stringWithFormat:@"%i小时后回收",(int)tInterval/HOUR_OF_SECONDS];
                }else {
                    NSInteger count = tInterval/DAY_OF_SECONDS;
                    markInfo = [NSString stringWithFormat:@"%li天后回收",count];
                }
            }
        }
    }
    CGSize sizeMarkInfo = [CommonFuntion getSizeOfContents:markInfo Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-160 withHeight:20];
    self.labelMarkInfo.text = markInfo;
    self.labelMarkInfo.frame = CGRectMake(self.imgSplit.frame.origin.x+4, 26, sizeMarkInfo.width, 20);
    
    
    ///按钮
    self.btnFollow.frame = CGRectMake(kScreen_Width-20-20, 15, 20, 20);
    self.btnFollow.hidden = YES;
    ///是否可关注
    BOOL canFollow = FALSE;
    if ([item objectForKey:@"canFollow"]) {
        canFollow = [[item objectForKey:@"canFollow"] boolValue];
    }
    
    ///是否被关注
    BOOL isFollow = FALSE;
    if ([item objectForKey:@"isFollow"]) {
        isFollow = [[item objectForKey:@"isFollow"] boolValue];
    }
    
    if (canFollow) {
        self.btnFollow.hidden = NO;
        NSString *iconFollowName = @"accessory_focus_normal.png";
        if (isFollow) {
            iconFollowName = @"accessory_focus_select.png";
        }else{
            iconFollowName = @"accessory_focus_normal.png";
        }
        [self.btnFollow setBackgroundImage:[UIImage imageNamed:iconFollowName] forState:UIControlStateNormal];
        
        ///添加点击事件
        self.btnFollow.tag = indexPath.row;
        [self.btnFollow addTarget:self action:@selector(followEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
}

///关注事件
-(void)followEvent:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    if (self.ccdelegate && [self.ccdelegate respondsToSelector:@selector(followCustomer:)]) {
        [self.ccdelegate followCustomer:tag];
    }
}

@end
