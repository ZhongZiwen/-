//
//  ContactBookPersonCell.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-24.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "ContactBookPersonCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"

@interface ContactBookPersonCell ()

@end

@implementation ContactBookPersonCell

- (void)setCellDataInfo:(ContactsInfo*)cInfo {
    
#warning 缺少isEqualToString:@"null"]的判断
    
    if ([cInfo.name isKindOfClass:[NSString class]] && ![cInfo.name isEqualToString:@"<null>"]) {
        labelUserName.text = cInfo.name;
    }
    
    if ([cInfo.jobNumber isKindOfClass:[NSString class]] && ![cInfo.jobNumber isEqualToString:@"<null>"]) {
        labelJobNumber.text = cInfo.jobNumber;
    }
    
    if ([cInfo.phoneNumber isKindOfClass:[NSString class]] && ![cInfo.phoneNumber isEqualToString:@"<null>"]) {
        labelPhoneNumber.text = cInfo.phoneNumber;
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


#pragma mark - UI适配
-(void)setCellViewFrame
{
    if (DEVICE_IS_IPHONE6) {
        [self setViewByIphone6];
        
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        [self setViewByIphone6];
    }
}

-(void)setViewByIphone6
{
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;
    
    img_info_icon.frame = [CommonFunc setViewFrameOffset:img_info_icon.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    view_line.frame = [CommonFunc setViewFrameOffset:view_line.frame byX:0 byY:0 ByWidth:vX byHeight:0];
    
    
    labelUserName.frame = [CommonFunc setViewFrameOffset:labelUserName.frame byX:0 byY:0 ByWidth:vX/3 byHeight:0];
    
    labelJobNumber.frame = [CommonFunc setViewFrameOffset:labelJobNumber.frame byX:vX/3 byY:0 ByWidth:2*vX/3 byHeight:0];
    labelPhoneNumber.frame = [CommonFunc setViewFrameOffset:labelPhoneNumber.frame byX:vX/3 byY:0 ByWidth:2*vX/3 byHeight:0];
    
}

@end
