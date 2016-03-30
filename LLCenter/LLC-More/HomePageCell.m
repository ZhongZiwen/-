//
//  HomePageCell.m
//  lianluozhongxin
//
//  Created by Vescky on 14-6-18.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "HomePageCell.h"
#import "LLCenterUtility.h"
#import "CommonFunc.h"

#define cell_height_normal 57.0f
#define cell_height_expanded 222.0f

@interface HomePageCell ()

@end

@implementation HomePageCell

- (void)setCellDataInfo:(CellDataInfo*)cInfo {
    //默认缩放图标隐藏
    if (cInfo.expandable) {
        imgvExpand.hidden = NO;
        imgvExpand.image = [UIImage imageNamed:@"btn_circle_up_blue.png"];
        CGRect eRect = expandedView.frame;//计算内容view的位置
        eRect.origin.y = cell_height_normal;
        expandedView.frame = eRect;
        [self.contentView addSubview:expandedView];
        
        NSDictionary *detailAccountInfo = [cInfo.cellDataInfo objectForKey:@"extra"];
        labelDetail1.text = [NSString stringWithFormat:@"%@元/年",[detailAccountInfo safeObjectForKey:@"minCost"]];
        labelDetail2.text = [NSString stringWithFormat:@"%@元/分钟",[detailAccountInfo safeObjectForKey:@"fee"]];
        labelDetail3.text = [NSString stringWithFormat:@"%@~%@",[detailAccountInfo objectForKey:@"activateTime"],[detailAccountInfo safeObjectForKey:@"colseTime"]];
        
        NSString *openFuntionString = [detailAccountInfo safeObjectForKey:@"openFunction"];
        openFuntionString = [openFuntionString stringByReplacingOccurrencesOfString:@"," withString:@"     "];
        
        
        NSString *closeFuntionString = [detailAccountInfo safeObjectForKey:@"colseFunction"];
        closeFuntionString = [closeFuntionString stringByReplacingOccurrencesOfString:@"," withString:@"     "];
        
        float label4Height = getTextHeightForLabelWithLineHeight(openFuntionString, labelDetail4.frame.size.width,20.0, [UIFont systemFontOfSize:15.0]);
        CGRect label4Rect = labelDetail4.frame;
        label4Rect.size.height = label4Height;
        labelDetail4.numberOfLines = 0;
        labelDetail4.frame = label4Rect;
        labelDetail4.lineBreakMode = 0;
        labelDetail4.text = openFuntionString;
        
        float label5Height = getTextHeightForLabelWithLineHeight(closeFuntionString, labelDetail5.frame.size.width,20.0, [UIFont systemFontOfSize:15.0]);
        CGRect label5Rect = labelDetail5.frame;
        label5Rect.size.height = label5Height;
        label5Rect.origin.y = label4Rect.origin.y + label4Rect.size.height + 5.0f;
        labelDetail5.frame = label5Rect;
        labelDetail5.lineBreakMode = 0;
        labelDetail5.numberOfLines = 0;
        labelDetail5.text = closeFuntionString;
        
    }
    else {
        self.userInteractionEnabled = NO;
    }
    
    //是否处于放大状态
    if (cInfo.expanded) {
        //放大状态
        imgvExpand.image = [UIImage imageNamed:@"btn_circle_up_blue.png"];
//        NSDictionary *detailAccountInfo = [cInfo.cellDataInfo objectForKey:@"extra"];
//        labelDetail1.text = [NSString stringWithFormat:@"%@元/年",[detailAccountInfo objectForKey:@"minCost"]];
//        labelDetail2.text = [NSString stringWithFormat:@"%@元/分钟",[detailAccountInfo objectForKey:@"fee"]];
//        labelDetail3.text = [NSString stringWithFormat:@"%@~%@",[detailAccountInfo objectForKey:@"activateTime"],[detailAccountInfo objectForKey:@"colseTime"]];
//        
//        NSString *openFuntionString = [detailAccountInfo objectForKey:@"openFunction"];
//        openFuntionString = [openFuntionString stringByReplacingOccurrencesOfString:@"," withString:@"     "];
//        
//        NSString *closeFuntionString = [detailAccountInfo objectForKey:@"colseFunction"];
//        closeFuntionString = [closeFuntionString stringByReplacingOccurrencesOfString:@"," withString:@"     "];
//        
//        float label4Height = getTextHeightForLabel(openFuntionString, labelDetail4.frame.size.width, [UIFont systemFontOfSize:15.0]);
//        CGRect label4Rect = labelDetail4.frame;
//        label4Rect.size.height = label4Height;
//        labelDetail4.numberOfLines = 0;
//        labelDetail4.frame = label4Rect;
//        labelDetail4.lineBreakMode = 1;
//        labelDetail4.text = openFuntionString;
//        
//        float label5Height = getTextHeightForLabel(closeFuntionString, labelDetail5.frame.size.width, [UIFont systemFontOfSize:15.0]);
//        CGRect label5Rect = labelDetail5.frame;
//        label5Rect.size.height = label5Height;
//        label5Rect.origin.y = label4Rect.origin.y + label4Rect.size.height + 5.0f;
//        labelDetail5.frame = label5Rect;
//        labelDetail5.text = closeFuntionString;
//
//        //计算cell的大小
//        __block CGRect cRect = self.frame;
//        cRect.size.height = cell_height_normal + label5Rect.origin.y + label5Height + 10;
//        [self setFrame:cRect];

        
    }
    else {
        //缩小状态
        imgvExpand.image = [UIImage imageNamed:@"btn_circle_down_blue.png"];
//        [expandedView removeFromSuperview];
//        
//        //计算cell的大小
//        __block CGRect cRect = self.frame;
//        cRect.size.height = cell_height_normal;
//        
//        [self setFrame:cRect];
    }
    
    [imgvIcon setImage:[UIImage imageNamed:[cInfo.cellDataInfo objectForKey:@"itemIcon"]]];
    labelItemName.text = [cInfo.cellDataInfo safeObjectForKey:@"itemName"];
    
    NSString *contentString = [cInfo.cellDataInfo safeObjectForKey:@"itemContent"];
    
//    NSLog(@"contentString:%@",contentString);
    /*
    if (contentString.length > 12) {
        contentString = [contentString substringToIndex:12];
    }
     */
    labelItemContent.text = contentString;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (float)getCellHeight:(CellDataInfo*)cInfo {
    if (!cInfo.expandable) {
        return cell_height_normal;
    }
    else {
        NSDictionary *detailAccountInfo = [cInfo.cellDataInfo objectForKey:@"extra"];
        NSString *openFuntionString = [detailAccountInfo safeObjectForKey:@"openFunction"];
        openFuntionString = [openFuntionString stringByReplacingOccurrencesOfString:@"," withString:@"     "];
        NSString *closeFuntionString = [detailAccountInfo safeObjectForKey:@"colseFunction"];
        closeFuntionString = [closeFuntionString stringByReplacingOccurrencesOfString:@"," withString:@"     "];
        
        
        float label4Height = getTextHeightForLabelWithLineHeight(openFuntionString, labelDetail4.frame.size.width,20.0, [UIFont systemFontOfSize:15.0]);
        float label5Height = getTextHeightForLabelWithLineHeight(closeFuntionString, labelDetail5.frame.size.width,20.0, [UIFont systemFontOfSize:15.0]);
        return cell_height_expanded + label4Height + label5Height - 40;
    }
}

- (void)setButtonSelected:(bool)isSelected {
    if (!isSelected) {
        imgvExpand.image = [UIImage imageNamed:@"btn_circle_down_blue.png"];
    }
    else {
        imgvExpand.image = [UIImage imageNamed:@"btn_circle_up_blue.png"];
    }
}


// UI 适配
-(void)setCellViewFrame
{
    if (DEVICE_IS_IPHONE6) {
        
        [self setViewFrameFor6];
    }else if(DEVICE_IS_IPHONE6_PLUS)
    {
        [self setViewFrameFor6];
    }else if(!DEVICE_IS_IPHONE5)
    {
        
    }else
    {
        
    }
    
    NSInteger vX = DEVICE_BOUNDS_WIDTH-320;
    
    expandedView.frame = [CommonFunc setViewFrameOffset:expandedView.frame byX:0 byY:0 ByWidth:vX byHeight:150];
}

-(void)setViewFrameFor6
{
//    NSLog(@"--setViewFrameFor6-->");
    NSInteger vX1 = DEVICE_BOUNDS_WIDTH-320;
    imgvExpand.frame = [CommonFunc setViewFrameOffset:imgvExpand.frame byX:vX1 byY:0 ByWidth:0 byHeight:0];
    view_line.frame = [CommonFunc setViewFrameOffset:view_line.frame byX:0 byY:0 ByWidth:vX1 byHeight:0];
    
    labelItemContent.frame = [CommonFunc setViewFrameOffset:labelItemContent.frame byX:0 byY:0 ByWidth:vX1-15 byHeight:0];
    
    btnExBg.frame = [CommonFunc setViewFrameOffset:btnExBg.frame byX:0 byY:0 ByWidth:vX1 byHeight:150];
    
    /*
    labelTag1.frame = [CommonFunc setViewFrameOffset:labelTag1.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    labelTag2.frame = [CommonFunc setViewFrameOffset:labelTag2.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    labelTag3.frame = [CommonFunc setViewFrameOffset:labelTag3.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    labelTag4.frame = [CommonFunc setViewFrameOffset:labelTag4.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    
    labelDetail1.frame = [CommonFunc setViewFrameOffset:labelDetail1.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    labelDetail2.frame = [CommonFunc setViewFrameOffset:labelDetail2.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    labelDetail3.frame = [CommonFunc setViewFrameOffset:labelDetail3.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    labelDetail4.frame = [CommonFunc setViewFrameOffset:labelDetail4.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
    labelDetail5.frame = [CommonFunc setViewFrameOffset:labelDetail5.frame byX:vX/2 byY:0 ByWidth:0 byHeight:0];
     */
    
}


@end
