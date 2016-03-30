//
//  NoAnSwerCell.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "NoAnSwerCell.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"


@implementation NoAnSwerCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellDetails:(NSDictionary *)item{
    
    self.btnSelectIcon.frame = CGRectMake(25, 14, 18, 18);
    
    NSString *content = [item objectForKey:@"SMSTEMPLATE"];
    CGSize sizeContent = [CommonFunc getSizeOfContents:content Font:[UIFont systemFontOfSize:14.0] withWidth:DEVICE_BOUNDS_WIDTH-40-15 withHeight:2999];
    self.labelMsgContent.text = content;
    self.labelMsgContent.frame = CGRectMake(55, 13, DEVICE_BOUNDS_WIDTH-55-15, sizeContent.height);
    
    ///匹配ID  修改图片
    
    
}

+(CGFloat)getCellHeight:(NSDictionary *)item{
    
    NSString *content = [item objectForKey:@"SMSTEMPLATE"];
    CGSize sizeContent = [CommonFunc getSizeOfContents:content Font:[UIFont systemFontOfSize:14.0] withWidth:DEVICE_BOUNDS_WIDTH-55-15 withHeight:2999];
    
    NSLog(@"getCellHeight:%f",sizeContent.height);
    
    
    return sizeContent.height+26;
}

@end
