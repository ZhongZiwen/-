//
//  SaleLeadSearchCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SaleLeadSearchCell.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "CommonModuleFuntion.h"


@implementation SaleLeadSearchCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


///设置cell详情
-(void)setCellDetails:(NSDictionary *)item{
    
    ///name
    NSString *name = @"";
    if ([item objectForKey:@"name"]) {
        name = [item safeObjectForKey:@"name"];
    }
    CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:[UIFont systemFontOfSize:15.0] withWidth:kScreen_Width-100 withHeight:20];
    self.labelName.frame = CGRectMake(15, 5, sizeName.width, 20);
    self.labelName.text = name;
    
  
    /// status [未处理]
    self.labelStatus.frame = CGRectMake(self.labelName.frame.origin.x+sizeName.width+5, 7, 100, 15);
    NSString *status = @"";
    status = [CommonModuleFuntion getSaleLeadStatusName:[[item objectForKey:@"status"] integerValue]];
    self.labelStatus.text = [NSString stringWithFormat:@"[%@]",status];
    
    
    ///companyname
    NSString *companyName = @"";
    if ([item objectForKey:@"companyName"]) {
        companyName = [item safeObjectForKey:@"companyName"];
    }
    self.labelCompanyName.frame = CGRectMake(15, 28, kScreen_Width-40, 20);
    self.labelCompanyName.text = companyName;
    
    
    NSInteger highSeaStatus = -1;
    if ([item objectForKey:@"highSeaStatus"]) {
        highSeaStatus = [[item safeObjectForKey:@"highSeaStatus"] integerValue];
    }
     NSString *highSeaStatusStr = [CommonModuleFuntion getHighSeaStatusName:highSeaStatus];
#warning status为空的情况
    if ([highSeaStatusStr isEqualToString:@""]) {
        
    }
#warning 图标
    ///图标
    self.imgIcon.frame = CGRectMake(15, 55, 10, 10);
    
   
    self.labelHighSeaStatus.text = highSeaStatusStr;
    
    CGSize sizeStatusName = [CommonFuntion getSizeOfContents:highSeaStatusStr Font:[UIFont systemFontOfSize:14.0] withWidth:kScreen_Width-120 withHeight:20];
    self.labelHighSeaStatus.frame = CGRectMake(30, 50, sizeStatusName.width, 20);
    
    
    ///split
    self.imgSplit.frame = CGRectMake(self.labelHighSeaStatus.frame.origin.x+sizeStatusName.width+2, 55, 1, 10);
    
    ///expireTime
    NSString *markInfo = @"";
    if ([item objectForKey:@"expireTime"]) {
        
        if ([[item objectForKey:@"expireTime"] longLongValue] <= 0 ) {
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
    self.labelMarkInfo.frame = CGRectMake(self.imgSplit.frame.origin.x+4, 50, sizeMarkInfo.width, 20);
}



@end
