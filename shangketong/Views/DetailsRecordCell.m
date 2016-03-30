//
//  DetailsRecordCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailsRecordCell.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "CommonModuleFuntion.h"

@implementation DetailsRecordCell

- (void)awakeFromNib {
    // Initialization code
    self.contentView.backgroundColor = VIEW_BG_COLOR;
    
   self.imgLineTop.image = [CommonFuntion createImageWithColor:COLOR_CELL_SPLIT_LINE];
    self.imgLineBottom.image = [CommonFuntion createImageWithColor:COLOR_CELL_SPLIT_LINE];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


///设置当前cell内容
-(void)setCellDetails:(NSDictionary *)preItem andCurItem:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    
    ///user
    NSDictionary *user = nil;
    if ([item objectForKey:@"user"]) {
        user = [item objectForKey:@"user"];
    }
    
    NSString *name = @"";
    if (user) {
        ///姓名
        if ([user objectForKey:@"name"]) {
            name = [user safeObjectForKey:@"name"];
        }
    }
    
    ///stream
    NSDictionary *stream = nil;
    if ([item objectForKey:@"stream"]) {
        stream = [item objectForKey:@"stream"];
    }
    NSString *acttach = @"";
    NSInteger action = -1;
    NSInteger type = -1;
    NSInteger system = -1;
    if (stream) {
        ///acttach
        if ([stream objectForKey:@"acttach"]) {
            acttach = [stream safeObjectForKey:@"acttach"];
        }
        if ([stream objectForKey:@"action"]) {
            action = [[stream safeObjectForKey:@"action"] integerValue];
        }
    }
    
    if ([item objectForKey:@"type"]) {
        type = [[item safeObjectForKey:@"type"] integerValue];
    }
    
    if ([item objectForKey:@"system"]) {
        system = [[item safeObjectForKey:@"system"] integerValue];
    }
    
    NSString *actionName = @"";
    actionName = [CommonModuleFuntion getActionsNameByType:type andSystem:system andAction:action];
    
    
    ///content
    NSString *content = @"";
    if ([item objectForKey:@"content"]) {
        content = [NSString stringWithFormat:@",%@",[item safeObjectForKey:@"content"]];
    }
    
    NSString *allContent = [NSString stringWithFormat:@"%@%@%@%@",name,actionName,content,acttach];
//    NSLog(@"allContent:%@",allContent);
    

    UIColor *colorDefault = [UIColor blackColor];
    UIColor *colorContent = [UIColor colorWithRed:35.0f/255 green:132.0f/255 blue:216.0f/255 alpha:1.0f];
    
    NSMutableAttributedString *attriStrContent = [[NSMutableAttributedString alloc] initWithString:allContent];
    [attriStrContent addAttribute:NSForegroundColorAttributeName value:colorDefault range:NSMakeRange(0,name.length)];
    [attriStrContent addAttribute:NSForegroundColorAttributeName value:colorDefault range:NSMakeRange(name.length,actionName.length)];
    [attriStrContent addAttribute:NSForegroundColorAttributeName value:colorContent range:NSMakeRange(name.length+actionName.length,content.length)];
    [attriStrContent addAttribute:NSForegroundColorAttributeName value:colorDefault range:NSMakeRange(name.length+actionName.length+content.length,acttach.length)];
    self.labelContent.attributedText = attriStrContent;
    
    CGSize sizeAllContent = [CommonFuntion getSizeOfContents:allContent Font:FONT_DETAILS_USER_NAME withWidth:240 withHeight:MAX_WIDTH_OR_HEIGHT];
    
    ///time
    long long date = 0;
    if ([item objectForKey:@"date"]) {
        date = [[item safeObjectForKey:@"date"] longLongValue];
    }
    
    self.labelTime.text = [CommonFuntion transDateWithTimeInterval:date withFormat:DATE_FORMAT_HHmm];
    
    CGFloat yPoint = 0;
    self.viewDate.hidden = YES;
    self.viewDate.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewDate.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewDate];
    
    ///date是否显示
#warning date是否显示  如显示 在date view上加10
   
    NSString *splitDate = [self showSplitDate:preItem andCurItem:item];
    
    if (![splitDate isEqualToString:@""]) {
//         NSLog(@"显示 splitDate:%@",splitDate);
        self.viewDate.hidden = NO;
        yPoint += 10;
        self.viewDate.frame = CGRectMake(0, yPoint, kScreen_Width, 15);
        yPoint += 15;
    }
    
    ///竖线
    self.imgLineTop.frame = CGRectMake(20, yPoint, 1, 10);
    yPoint += 10;
    
    [self.btnDate setTitle:splitDate forState:UIControlStateNormal];
    
    ///图标
    self.imgActionIcon.frame = CGRectMake(13, yPoint, 13, 13);
    self.labelTime.frame = CGRectMake(kScreen_Width-60, yPoint-3, 50, 20);
    self.labelContent.frame = CGRectMake(35, yPoint, sizeAllContent.width, sizeAllContent.height);
    
    self.imgLineBottom.frame = CGRectMake(20, yPoint+13+5, 1, sizeAllContent.height-13-5+10);
}


///将当前行日期与上一行日期做比较 如果不是同一天则显示
-(BOOL)isShowCurDateForSplitDate:(NSDictionary *)preItem andCurItem:(NSDictionary *)item{
    BOOL isShow = FALSE;
    ///date_pre
    long long date_pre = 0;
    if (preItem && [preItem objectForKey:@"date"]) {
        date_pre = [[preItem safeObjectForKey:@"date"] longLongValue];
    }
    
    ///date_cur
    long long date_cur = 0;
    if (item && [item objectForKey:@"date"]) {
        date_cur = [[item safeObjectForKey:@"date"] longLongValue];
    }
    
    ///第一行
    if (date_pre == 0) {
        isShow = TRUE;
    }else{
        /// 判断是否同一天
        if ([[CommonFuntion transDateWithTimeInterval:date_pre withFormat:DATE_FORMAT_yyyyMMdd] isEqualToString:[CommonFuntion transDateWithTimeInterval:date_cur withFormat:DATE_FORMAT_yyyyMMdd]]) {
            isShow = FALSE;
        }else{
            isShow = TRUE;
        }
    }
    return isShow;
}

///比较上一行与当前行的date  判断当前行是否显示分隔日期
-(NSString *)showSplitDate:(NSDictionary *)preItem andCurItem:(NSDictionary *)item{
    NSString *splitDate = @"";
    
    BOOL isShow = [self isShowCurDateForSplitDate:preItem andCurItem:item];
    if (isShow) {
        /// 根据当前行日期 获取对应格式的日期格式
        /// 今天、昨天、月日、年月日
        ///date_cur
        long long date_cur = 0;
        if (item && [item objectForKey:@"date"]) {
            date_cur = [[item safeObjectForKey:@"date"] longLongValue];
        }
        splitDate = [CommonFuntion formateLongDate:date_cur];
    }
    return splitDate;
}

///获取全部内容
-(NSString *)getAllContent:(NSDictionary *)item{
    ///user
    NSDictionary *user = nil;
    if ([item objectForKey:@"user"]) {
        user = [item objectForKey:@"user"];
    }
    
    NSString *name = @"";
    if (user) {
        ///姓名
        if ([user objectForKey:@"name"]) {
            name = [user safeObjectForKey:@"name"];
        }
    }
    
    ///stream
    NSDictionary *stream = nil;
    if ([item objectForKey:@"stream"]) {
        stream = [item objectForKey:@"stream"];
    }
    NSString *acttach = @"";
    NSInteger action = -1;
    NSInteger type = -1;
    NSInteger system = -1;
    if (stream) {
        ///acttach
        if ([stream objectForKey:@"acttach"]) {
            acttach = [stream safeObjectForKey:@"acttach"];
        }
        if ([stream objectForKey:@"action"]) {
            action = [[stream safeObjectForKey:@"action"] integerValue];
        }
    }
    
    if ([item objectForKey:@"type"]) {
        type = [[item safeObjectForKey:@"type"] integerValue];
    }
    
    if ([item objectForKey:@"system"]) {
        system = [[item safeObjectForKey:@"system"] integerValue];
    }
    
    NSString *actionName = @"";
    actionName = [CommonModuleFuntion getActionsNameByType:type andSystem:system andAction:action];
    
    ///content
    NSString *content = @"";
    if ([item objectForKey:@"content"]) {
        content = [NSString stringWithFormat:@",%@",[item safeObjectForKey:@"content"]];
    }
    ///
    NSString *allContent = [NSString stringWithFormat:@"%@%@%@%@",name,actionName,content,acttach];
    
    return allContent;
}


///根据content  计算cell height
+(CGFloat)getCellContentHeight:(NSDictionary *)preItem andCurItem:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0.0;
    
#warning date是否显示  如显示 在date view上加10
    NSString *splitDate = [[self new] showSplitDate:preItem andCurItem:item];
    if (![splitDate isEqualToString:@""]) {
        height += 10;
        height += 15;
    }
    
    ///竖线
    height += 10;
    
    NSString *allContent = [[self new] getAllContent:item];
    CGSize sizeAllContent = [CommonFuntion getSizeOfContents:allContent Font:FONT_DETAILS_USER_NAME withWidth:240 withHeight:MAX_WIDTH_OR_HEIGHT];
    height += (sizeAllContent.height+10);
    return height;
}

///label添加点击手势
-(void)addClickEvent:(NSIndexPath *)indexPath{
    self.labelContent.userInteractionEnabled = YES;
    self.labelContent.tag = indexPath.row-1;
    UITapGestureRecognizer *contentTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(contentTouchUpInside:)];
    [self.labelContent addGestureRecognizer:contentTapGestureRecognizer];
}

///点击事件
-(void)contentTouchUpInside:(UITapGestureRecognizer *)tap{
    UILabel *tapLabel = (UILabel *)tap.view;
    NSString *tagIndex = [NSString stringWithFormat:@"%li",tapLabel.tag];
    NSLog(@"tagIndex:%@",tagIndex);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickDetailRecordEvent:)]) {
        [self.delegate clickDetailRecordEvent:tapLabel.tag];
    }
}

@end
