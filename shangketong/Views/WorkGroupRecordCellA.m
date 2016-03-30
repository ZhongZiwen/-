//
//  WorkGroupRecordCellA.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WorkGroupRecordCellA.h"
#import "UIButton+WebCache.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"

@implementation WorkGroupRecordCellA

- (void)awakeFromNib {
    // Initialization code
    
    self.btnIcon.layer.cornerRadius = 3;
    self.btnIcon.imageView.layer.cornerRadius = 3;
    
    self.btnFrom.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    

    self.labelName.font = FONT_WORKGROUP_NAME;
    self.labelContent.font = FONT_WORKGROUP_CONTENT;
    
    
    self.clipsToBounds = YES;
    UIColor *color = [UIColor colorWithRed:247.0f/255 green:247.0f/255 blue:247.0f/255 alpha:1.0f];
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame] ;
    self.selectedBackgroundView.backgroundColor = color;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - 填充详情
///
-(void)setContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    
    CGFloat yPoint = 10;
    
    ///头部信息
    yPoint = [self getYPointByContentIsHeadView:item andYPoint:yPoint];
    yPoint = 58;
    ///content信息
    yPoint = [self getYPointByContentIsContent:item andYPoint:yPoint];
}

#pragma mark  头部view  头像姓名等
-(CGFloat)getYPointByContentIsHeadView:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    ///user
    NSDictionary *user = nil;
    if ([item objectForKey:@"user"]) {
        user = [item objectForKey:@"user"];
    }
    
    NSString *name = @"";
    NSString *icon = @"";
    if (user) {
        ///姓名
        if ([user objectForKey:@"name"]) {
            name = [user safeObjectForKey:@"name"];
        }
        ///头像
        if ([user objectForKey:@"icon"]) {
            icon = [user safeObjectForKey:@"icon"];
        }
    }
    
    self.btnIcon.frame = CGRectMake(10, yPoint, 30, 30);
    [self.btnIcon sd_setImageWithURL:[NSURL URLWithString:icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
    
    
    CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:FONT_WORKGROUP_NAME withWidth:kScreen_Width-100 withHeight:20];
    self.labelName.frame = CGRectMake(50, 7, sizeName.width, 20);
    self.labelName.text = name;
    
    ///date
    long long date = 0;
    if ([item objectForKey:@"date"]) {
        date = [[item safeObjectForKey:@"date"] longLongValue];
    }
    NSString *strDate = [CommonFuntion commentOrTrendsDateCommonByLong:date];;
    CGSize sizeDate = [CommonFuntion getSizeOfContents:strDate Font:FONT_WORKGROUP_DATE withWidth:MAX_WIDTH_OR_HEIGHT withHeight:20];
    self.labelDate.frame = CGRectMake(50, 25, sizeDate.width, 20);
    self.labelDate.text = strDate;
    
    NSLog(@"date:%@",[CommonFuntion transDateWithTimeInterval:date withFormat:DATE_FORMAT_MMddHHmm]);
    
    
    ///from
    NSDictionary *from = nil;
    if ([item objectForKey:@"from"]) {
        from = [item objectForKey:@"from"];
    }
    NSString *fromname = @"";
    NSString *frombelongName = @"";
    if (from) {
        if ([from objectForKey:@"name"]) {
            fromname = [from safeObjectForKey:@"name"];
        }
        if ([from objectForKey:@"belongName"]) {
            frombelongName = [from safeObjectForKey:@"belongName"];
        }
    }
    
    self.btnFrom.hidden = YES;
    if (![frombelongName isEqualToString:@""]) {
        self.btnFrom.hidden = NO;
        NSString *belongContent = [NSString stringWithFormat:@"来自%@ (%@)",frombelongName,fromname];
        CGSize sizeBelongContent = [CommonFuntion getSizeOfContents:belongContent Font:FONT_WORKGROUP_DATE withWidth:kScreen_Width-150 withHeight:20];
        
        self.btnFrom.frame = CGRectMake(self.labelDate.frame.origin.x+sizeDate.width+5, 25, sizeBelongContent.width, 20);
        [self.btnFrom setTitle:belongContent forState:UIControlStateNormal];
        
    }
    return newYPoint;
}

#pragma mark  正文content
-(CGFloat)getYPointByContentIsContent:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    ///content
    NSString *content = @"";
    if ([item objectForKey:@"content"]) {
        content = [item safeObjectForKey:@"content"];
    }
    self.labelContent.hidden = YES;
    if (![content isEqualToString:@""]) {
        self.labelContent.hidden = NO;
        CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_WORKGROUP_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
        
        self.labelContent.frame = CGRectMake(10, yPoint, sizeContent.width, sizeContent.height);
        self.labelContent.text = content;
        
        newYPoint += (sizeContent.height+10);
    }
    NSLog(@"content:%@",content);
    return newYPoint;
}


#pragma mark - 获取当前cell height
///获取height
+(CGFloat)getCellContentHeight:(NSDictionary *)item{
    CGFloat height = 58;
    NSString *content = @"";
    if ([item objectForKey:@"content"]) {
        content = [item safeObjectForKey:@"content"];
    }

    ///content
    if (![content isEqualToString:@""]) {
        CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_WORKGROUP_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
        height += (sizeContent.height+10);
    }
    return height;
}

@end
