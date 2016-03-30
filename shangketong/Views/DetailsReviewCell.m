//
//  DetailsReviewCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "DetailsReviewCell.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "User.h"

@interface DetailsReviewCell () {
    NSDictionary *itemInfo;
}

@end

@implementation DetailsReviewCell

- (void)awakeFromNib {
    // Initialization code
//    self.contentView.backgroundColor = VIEW_BG_COLOR;
    
    self.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
    self.btnIcon.layer.cornerRadius = 3;
    self.btnIcon.imageView.layer.cornerRadius = 3;
    self.btnAddress.layer.cornerRadius = 3;
    
    self.imgFileBg.layer.cornerRadius = 2;
    
    
    self.imgCellSplit.image = [CommonFuntion createImageWithColor:COLOR_CELL_SPLIT_LINE];
    
    self.viewBg.layer.cornerRadius = 1;
    self.btnAddress.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.labelBelongName.font = FONT_DETAILS_BELONGNAME_NAME;
    self.labelName.font = FONT_DETAILS_USER_NAME;
    self.labelContent.font = FONT_DETAILS_CONTENT;
    self.labelContent.textColor = [UIColor colorWithHexString:@"0x222222"];
    self.labelContent.numberOfLines = 0;
    self.labelContent.linkAttributes = kLinkAttributes;
    self.labelContent.activeLinkAttributes = kLinkAttributesActive;
    
    self.btnReviewCount.titleLabel.font = FONT_DETAILS_BELONGNAME_NAME;
    
    self.btnAddress.titleLabel.font = FONT_DETAILS_CONTENT;
    
    self.labelVoiceDuration.font = FONT_DETAILS_CONTENT;
    
    self.labelTaskContent.font = FONT_DETAILS_CONTENT;
    
    self.img1.contentMode = UIViewContentModeScaleAspectFill;
    self.img2.contentMode = UIViewContentModeScaleAspectFill;
    self.img3.contentMode = UIViewContentModeScaleAspectFill;
    self.img4.contentMode = UIViewContentModeScaleAspectFill;
    self.img5.contentMode = UIViewContentModeScaleAspectFill;
    self.img6.contentMode = UIViewContentModeScaleAspectFill;
    self.img7.contentMode = UIViewContentModeScaleAspectFill;
    self.img8.contentMode = UIViewContentModeScaleAspectFill;
    self.img9.contentMode = UIViewContentModeScaleAspectFill;
    self.img1.clipsToBounds = YES;
    self.img2.clipsToBounds = YES;
    self.img3.clipsToBounds = YES;
    self.img4.clipsToBounds = YES;
    self.img5.clipsToBounds = YES;
    self.img6.clipsToBounds = YES;
    self.img7.clipsToBounds = YES;
    self.img8.clipsToBounds = YES;
    self.img9.clipsToBounds = YES;
    
    self.clipsToBounds = YES;
    UIColor *color = [UIColor colorWithRed:247.0f/255 green:247.0f/255 blue:247.0f/255 alpha:1.0f];
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame] ;
    self.selectedBackgroundView.backgroundColor = color;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

///根据内容设置view frame
-(void)setCellFrame:(NSDictionary *)item{
    NSInteger vX = kScreen_Width-320;//
    CGFloat yPoint = 25;
    
    vX -= 10;
    

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
//        NSLog(@"当前item显示日期:%@",item);
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


#pragma mark - 设置cell 内容
-(void)setCellDetails:(NSDictionary *)preItem andCurItem:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    
    itemInfo = item;
    
    CGFloat yPoint = 0;
    CGFloat yBgPoint = 0;
    
    self.viewDate.hidden = YES;
    self.viewDate.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewDate.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewDate];
    
    
    #warning date是否显示  如显示 在date view上加10
    NSString *splitDate = [self showSplitDate:preItem andCurItem:item];
    
    if (![splitDate isEqualToString:@""]) {
        NSLog(@"显示 splitDate:%@",splitDate);
        self.viewDate.hidden = NO;
        yPoint += 10;
        self.viewDate.frame = CGRectMake(0, yPoint, kScreen_Width, 15);
        yPoint += 15;
    }
    [self.btnDate setTitle:splitDate forState:UIControlStateNormal];
    
    
#warning 竖线高度控制
    ///竖线
    self.imgCellSplit.frame = CGRectMake(20, yPoint, 1, 10);
    yPoint += 10;
    yBgPoint = yPoint;
    [self bringSubviewToFront:self.imgLineTop];
    
    ///Head部分
    yPoint = 25;
    yPoint = [self getYPointByContentIsHeadView:item andYPoint:yPoint];

    /// 头像等信息
    yPoint = [self getYPointByContentIsIconNameCount:item andYPoint:yPoint];
    ///正文信息
    yPoint = [self getYPointByContentIsContent:item andYPoint:yPoint];
    
    yPoint += yBgPoint;

    
    ///任务信息
    yPoint = [self getYPointByTaskContent:item andYPoint:yPoint];
    
    ///语音信息
    yPoint = [self getYPointByContentIsVoice:item andYPoint:yPoint];
    
    ///文件信息
    yPoint = [self getYPointByContentIsFile:item andYPoint:yPoint];
    
    ///地址信息
    yPoint = [self getYPointByContentIsLocation:item andYPoint:yPoint];
    
    ///图片信息
    yPoint = [self getYPointByContentIsImg:item andYPoint:yPoint];
    
    ///
    self.viewBg.frame = CGRectMake(5, yBgPoint, kScreen_Width-10, yPoint-yBgPoint);
    self.imgBg.frame = CGRectMake(0, 0, kScreen_Width-10, yPoint-yBgPoint);
    self.imgBg.image = [CommonFuntion createImageWithColor:[UIColor whiteColor]];
    
    [self bringSubviewToFront:self.labelContent];
    
}


#pragma mark  头部view
-(CGFloat)getYPointByContentIsHeadView:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    
    self.imgActivityFeedIcon.frame = CGRectMake(10, 8, 10, 10);
    self.imgLine.frame = CGRectMake(5, 25, kScreen_Width-20, 1);
    self.imgLine.image = [CommonFuntion createImageWithColor:VIEW_BG_COLOR];
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
    self.labelBelongName.hidden = YES;
    if (![frombelongName isEqualToString:@""]) {
        self.labelBelongName.hidden = NO;
        NSString *belongContent = [NSString stringWithFormat:@"来自%@ (%@)",frombelongName,fromname];
        CGSize sizeBelongContent = [CommonFuntion getSizeOfContents:belongContent Font:FONT_DETAILS_BELONGNAME_NAME withWidth:kScreen_Width-100 withHeight:20];
        
        self.labelBelongName.frame = CGRectMake(30, 3, sizeBelongContent.width, 20);
        self.labelBelongName.text = belongContent;
        NSLog(@"belongContent:%@",belongContent);
    }
    
    
    ///date
    long long date = 0;
    if ([item objectForKey:@"date"]) {
        date = [[item safeObjectForKey:@"date"] longLongValue];
    }
    
    self.labelDate.frame = CGRectMake(kScreen_Width-70, 3, 50, 20);
    self.labelDate.text = [CommonFuntion transDateWithTimeInterval:date withFormat:DATE_FORMAT_MM_dd];
    
    NSLog(@"date:%@",[CommonFuntion transDateWithTimeInterval:date withFormat:DATE_FORMAT_MM_dd]);
    
    newYPoint += 10;
    return newYPoint;
}

#pragma mark  头像姓名评论数等
-(CGFloat)getYPointByContentIsIconNameCount:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
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
    
    self.btnIcon.frame = CGRectMake(10, yPoint, 25, 25);
    [self.btnIcon sd_setImageWithURL:[NSURL URLWithString:icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
    
    
    CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:FONT_DETAILS_USER_NAME withWidth:kScreen_Width-100 withHeight:20];
    self.labelName.frame = CGRectMake(45, yPoint, sizeName.width, 20);
    self.labelName.text = name;
    
    NSLog(@"name:%@",name);
    NSLog(@"icon:%@",icon);
    
    ///comments count
    NSInteger commentsCount = 0;
    if ([item objectForKey:@"comments"]) {
        commentsCount = [[item safeObjectForKey:@"comments"] integerValue];
    }
    self.btnReviewCount.frame = CGRectMake(kScreen_Width-70, yPoint, 50, 20);
    [self.btnReviewCount setTitle:[NSString stringWithFormat:@" %li",commentsCount] forState:UIControlStateNormal];
    NSLog(@"commentsCount:%li",commentsCount);
    
    newYPoint += (25+10);
    return newYPoint;
}


#pragma mark  正文
-(CGFloat)getYPointByContentIsContent:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    
    ///content
    NSString *content = item[@"content"];

//    NSString *content = @"";
//    if ([item objectForKey:@"content"]) {
//        content = [NSString stringWithFormat:@"%@    ",[item safeObjectForKey:@"content"]];
//    }
    
    self.labelContent.hidden = YES;
    if (![content isEqualToString:@""]) {
        self.labelContent.hidden = NO;
        CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_DETAILS_CONTENT withWidth:kScreen_Width-30 withHeight:MAX_WIDTH_OR_HEIGHT];
        
        NSLog(@"sizeContent width:%f",sizeContent.width);
        NSLog(@"sizeContent height:%f",sizeContent.height);
        
        self.labelContent.frame = CGRectMake(10, yPoint, sizeContent.width, sizeContent.height);
        self.labelContent.text = content;
        
        newYPoint += (sizeContent.height+10);
    }
    
    // @人
    NSMutableArray *tempAltsArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *tempAltsDict in item[@"alts"]) {
        User *altUser = [NSObject objectOfClass:@"User" fromJSON:tempAltsDict];
        [tempAltsArray addObject:altUser];
    }
    
    for (User *tempUser in tempAltsArray) {
        
        // 找到重名的用户
        NSMutableArray *altUsersArray = [NSMutableArray arrayWithCapacity:0];
        for (User *altUser in tempAltsArray) {
            if ([altUser.name rangeOfString:tempUser.name].location != NSNotFound) {
                [altUsersArray addObject:altUser];
            }
        }
        
        // 从内容中找到@人的range
        NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:0];
        NSRange searchRange = NSMakeRange(0, [item[@"content"] length]);
        NSRange altRange;
        while ((altRange = [item[@"content"] rangeOfString:[NSString stringWithFormat:@"@%@", tempUser.name] options:0 range:searchRange]).location != NSNotFound) {
            [resultsArray addObject:[NSValue valueWithRange:altRange]];
            searchRange = NSMakeRange(NSMaxRange(altRange), [item[@"content"] length] - NSMaxRange(altRange));
        }
        
        NSInteger index = [altUsersArray indexOfObject:tempUser];
        if (index < resultsArray.count) {
            NSRange range = ((NSValue*)resultsArray[index]).rangeValue;
            [_labelContent addLinkToTransitInformation:@{@"altUser" : tempUser} withRange:range];
        }
    }
    
    return newYPoint;
}


#pragma mark 任务信息
-(CGFloat)getYPointByTaskContent:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = 0;
    
    self.viewTask.hidden = YES;
    self.viewTask.frame = CGRectMake(5, yPoint, 0, 0);
    self.viewTask.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewTask];
    ///任务recordNew

    ///客户recordNew  联系人无
    if (([item objectForKey:@"taskId"]) || ([item objectForKey:@"recordNew"] &&  [[item objectForKey:@"recordNew"] objectForKey:@"taskId"])) {
        self.viewTask.hidden = NO;
        
        NSDictionary *itemTask;
        
        if([item objectForKey:@"taskId"]){
            itemTask = item;
        }else{
            itemTask = [item objectForKey:@"recordNew"];
        }
        
        ///任务描述
        NSString *taskDescription = @"";
        if ([itemTask objectForKey:@"taskDescription"]) {
            taskDescription = [itemTask objectForKey:@"taskDescription"];
        }
        
        ///任务成员
        NSArray *arrayTaskMembers = nil;
        if ([itemTask objectForKey:@"taskMembers"]) {
            arrayTaskMembers = [itemTask objectForKey:@"taskMembers"];
        }
        NSString *taskMembers = [self getTaskMembersStr:arrayTaskMembers];
        ///内容不为空
        if (![taskDescription isEqualToString:@""] || ![taskMembers isEqualToString:@""]) {
            self.labelTaskContent.hidden = NO;
            NSString *taskContent = @"";
            if (![taskDescription isEqualToString:@""]) {
                taskContent = taskDescription;
            }
            if (![taskContent isEqualToString:@""]) {
                taskContent = [NSString stringWithFormat:@"%@\n%@",taskContent,taskMembers];
            }else{
                taskContent = taskMembers;
            };
            NSLog(@"taskContent:%@",taskContent);
            CGSize sizeTaskContent = [CommonFuntion getSizeOfContents:taskContent Font:FONT_DETAILS_CONTENT withWidth:kScreen_Width-30 withHeight:MAX_WIDTH_OR_HEIGHT];
            self.labelTaskContent.frame = CGRectMake(10, 0, sizeTaskContent.width, sizeTaskContent.height);
            self.labelTaskContent.text = taskContent;
            
            newYPoint += (sizeTaskContent.height+10);
        }else{
            self.labelTaskContent.frame = CGRectMake(5, 0, 0, 0);
            self.labelTaskContent.hidden = YES;
        }
        
        ///分割线
        self.imgTaskLine.frame = CGRectMake(0, newYPoint, kScreen_Width-10, 1);
        newYPoint += 1;
        ///底部 该任务于XXXXX由XX 创建
        NSString *taskCreatedByName =@"";
        if ([itemTask objectForKey:@"taskCreatedBy"] && [[itemTask objectForKey:@"taskCreatedBy"] objectForKey:@"name"]) {
            taskCreatedByName = [[itemTask objectForKey:@"taskCreatedBy"] objectForKey:@"name"];
        }
        ///创建时间
        NSString *taskCreatedAt = @"";
        if ([itemTask objectForKey:@"taskCreatedAt"] ) {
            taskCreatedAt = [CommonFuntion transDateWithTimeInterval:[[itemTask objectForKey:@"taskCreatedAt"] longLongValue] withFormat:DATE_FORMAT_yyyyMMddHHmm];
        }
        
        self.labelTaskMarkInfo.text = [NSString stringWithFormat:@"该任务于%@由%@ 创建",taskCreatedAt,taskCreatedByName];
 
        self.labelTaskMarkInfo.frame = CGRectMake(5, newYPoint+5, kScreen_Width-25, 20);
        newYPoint += 30;
        
        self.viewTask.frame = CGRectMake(5, yPoint, kScreen_Width-10, newYPoint);
        newYPoint += (yPoint);
    }else{
        newYPoint = yPoint;
    }
    
    return newYPoint;
}

///获取任务成员
-(NSString *)getTaskMembersStr:(NSArray *)arrayMembers{
    NSInteger count = 0;
    if (arrayMembers) {
        count = [arrayMembers count];
    }
    NSMutableString *strMembers = [[NSMutableString alloc] init];
    for (int i=0; i<count; i++) {
        
        if ([strMembers isEqualToString:@""]) {
            [strMembers appendString:[NSString stringWithFormat:@"参与人: %@",[[arrayMembers objectAtIndex:i] objectForKey:@"name"]]];
        }else{
            [strMembers appendString:@"、"];
            [strMembers appendString:[[arrayMembers objectAtIndex:i] objectForKey:@"name"]];
        }
    }
    return strMembers;
}

#pragma mark 语音信息
-(CGFloat)getYPointByContentIsVoice:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    ///sound
    self.viewVoice.hidden = YES;
    self.viewVoice.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewVoice.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewVoice];
    NSString *soundUrl = @"";
    if ([item objectForKey:@"soundUrl"]) {
        self.viewVoice.hidden = NO;
        soundUrl = [item safeObjectForKey:@"soundUrl"];
        
        NSString *soundDuration = @"";
        if ([item objectForKey:@"soundDuration"]) {
            soundDuration = [NSString stringWithFormat:@"%li''",[[item safeObjectForKey:@"soundDuration"] integerValue]];
        }
        
        self.viewVoice.frame = CGRectMake(10, yPoint-3, 100, 40);
        self.labelVoiceDuration.text = soundDuration;
        newYPoint += (40);
    }
    return newYPoint;
}

#pragma mark  是否有文件内容  是则计算其高度并返回
-(CGFloat)getYPointByContentIsFile:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    ///文件 type 0  文件
    self.viewFile.hidden = YES;
    self.viewFile.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewFile.backgroundColor = [UIColor clearColor];
    self.imgFileBg.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:240.0f/255 green:240.0f/255 blue:240.0f/255 alpha:1.0f]];
    [self addSubview:self.viewFile];
    
#warning type判断
    if ([item objectForKey:@"file"]) {
        if ([[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 0) {
            ///文件
            self.viewFile.hidden = NO;
            self.viewFile.frame = CGRectMake(10, yPoint, kScreen_Width-20, 40);
            self.imgFileBg.frame = CGRectMake(0, 0, kScreen_Width-20, 40);
            
            NSString *filename = @"";
            if ([[item objectForKey:@"file"] objectForKey:@"name"]) {
                filename = [[item objectForKey:@"file"] safeObjectForKey:@"name"];
            }
            self.labelFileName.text = filename;
//            self.btnFile.frame = CGRectMake(0, 0, kScreen_Width, 40);
//            [self.btnFile bringSubviewToFront:self];
            newYPoint += (40+10);
        }
    }
    
    
    if ([item objectForKey:@"recordNew"]) {
        if ([[item objectForKey:@"recordNew"] objectForKey:@"ftype"] && [[[item objectForKey:@"recordNew"] objectForKey:@"ftype"] integerValue] == 0) {
            ///文件
            self.viewFile.hidden = NO;
            self.viewFile.frame = CGRectMake(10, yPoint, kScreen_Width-20, 40);
            
            NSString *filename = @"";
            if ([[item objectForKey:@"recordNew"] objectForKey:@"fname"]) {
                filename = [[item objectForKey:@"recordNew"] safeObjectForKey:@"fname"];
            }
            self.labelFileName.text = filename;
//            self.btnFile.frame = CGRectMake(0, 0, kScreen_Width, 40);
//            [self.btnFile bringSubviewToFront:self];
            newYPoint += (40+10);
        }
    }
    
    return newYPoint;
}

#pragma mark  位置信息
-(CGFloat)getYPointByContentIsLocation:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    
    ///location
    NSString *location = @"";
    if ([item objectForKey:@"location"]) {
        location = [item safeObjectForKey:@"location"];
    }
    NSString *locationDetail = @"";
    if ([item objectForKey:@"locationDetail"]) {
        locationDetail = [item safeObjectForKey:@"locationDetail"];
    }
    
    self.viewAddress.hidden = YES;
    self.viewAddress.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewAddress.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewAddress];
    
    if (![location isEqualToString:@""]) {
        self.viewAddress.hidden = NO;
        
        NSLog(@"location:%@",location);
        [self.btnAddress setTitle:location forState:UIControlStateNormal];
        [self.btnAddress setBackgroundImage:[CommonFuntion createImageWithColor:VIEW_BG_COLOR] forState:UIControlStateNormal];
        self.labelAddress.text = locationDetail;
        self.labelAddressStreet.text = location;
        
        
        if ([self isContainPic:item]) {
            self.viewAddressContent.hidden = YES;
            self.viewAddress.frame = CGRectMake(10, yPoint+3, kScreen_Width-20, 20);
            newYPoint += (20+10);
            
        }else{
            self.viewAddressContent.hidden = NO;
            self.viewAddress.frame = CGRectMake(10, yPoint, kScreen_Width-20, 95);
            self.viewAddressContent.frame = CGRectMake(5, 25, kScreen_Width-30, 64);
            self.imgAddressBg.frame = CGRectMake(0, 0, kScreen_Width-30, 64);
            self.imgAddressBg.image = [CommonFuntion createImageWithColor:VIEW_BG_COLOR];
            newYPoint += (95+10);
        }
    }
    return newYPoint;
}

///判断是否包含图片 显示图片则不显示地址信息详情
-(BOOL)isContainPic:(NSDictionary *)item{
    BOOL isContain = FALSE;
    if ([item objectForKey:@"recordNew"] &&  [[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"]) {
        if([[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"]){
            isContain = TRUE;
        }
    }
    return isContain;
}

#pragma mark 图片信息
-(CGFloat)getYPointByContentIsImg:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    
    self.viewImage.hidden = YES;
    self.viewImage.frame = CGRectMake(10, yPoint, 0, 0);
//    self.viewImage.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewImage];
    ///图片recordNew
    [self setAllImgHide];
    //    self.viewImage.hidden = YES;
    
    ///客户 recordNew  联系人 file
    if (([item objectForKey:@"recordNew"] && [[[item objectForKey:@"recordNew"] objectForKey:@"ftype"] integerValue] == 1 && [[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"]) || ([item objectForKey:@"file"] && [[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 1 && [[item objectForKey:@"file"] objectForKey:@"imageFiles"])) {
        
        NSArray *arrayImg;
       ///联系人
        if([item objectForKey:@"file"] && [[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 1 && [[item objectForKey:@"file"] objectForKey:@"imageFiles"]){
            arrayImg = [[item objectForKey:@"file"] objectForKey:@"imageFiles"];
        }else{
            arrayImg = [[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"];
        }
        
        
        NSInteger count = [arrayImg count];
        if (count > 0) {
            self.viewImage.hidden = NO;
            [self setImgShow:count];
            NSLog(@"imgCount:%li",count);
            CGFloat imgHeight = [self getImgViewHeight:count];
            self.viewImage.frame = CGRectMake(10, yPoint, 200, imgHeight);
            newYPoint += (imgHeight+10);
        }
    }
    
    return newYPoint;
}

#pragma mark
-(CGFloat)getYPointByConteIsTest:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    
    return newYPoint;
}

#pragma mark - 获取cell height
+(CGFloat)getCellContentHeight:(NSDictionary *)preItem andCurItem:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
#warning date是否显示  如显示 在date view上加10
    NSString *splitDate = [[self new] showSplitDate:preItem andCurItem:item];
    if (![splitDate isEqualToString:@""]) {
        height += 10;
        height += 15;
    }
    
#warning 竖线高度控制
    ///竖线
    height += 10;

    // 顶部+头像部分
    height += (25+35);
    ///content
    NSString *content = [item safeObjectForKey:@"content"];
    
//    NSString *content = @"";
//    if ([item objectForKey:@"content"]) {
//        content = [NSString stringWithFormat:@"%@    ",[item safeObjectForKey:@"content"]];
//    }
    
    if (![content isEqualToString:@""]) {
        CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_DETAILS_CONTENT withWidth:kScreen_Width-30 withHeight:MAX_WIDTH_OR_HEIGHT];

        height += (sizeContent.height+10);
    }
    
    ///任务部分
    if (([item objectForKey:@"taskId"]) || ([item objectForKey:@"recordNew"] &&  [[item objectForKey:@"recordNew"] objectForKey:@"taskId"])) {
        NSInteger taskHeight = 0;
        NSDictionary *itemTask;
        
        if([item objectForKey:@"taskId"]){
            itemTask = item;
        }else{
            itemTask = [item objectForKey:@"recordNew"];
        }
        ///任务描述
        NSString *taskDescription = @"";
        if ([itemTask objectForKey:@"taskDescription"]) {
            taskDescription = [itemTask objectForKey:@"taskDescription"];
        }
        
        ///任务成员
        NSArray *arrayTaskMembers = nil;
        if ([itemTask objectForKey:@"taskMembers"]) {
            arrayTaskMembers = [itemTask objectForKey:@"taskMembers"];
        }
        NSString *taskMembers = [[self new] getTaskMembersStr:arrayTaskMembers];
        ///内容不为空
        if (![taskDescription isEqualToString:@""] || ![taskMembers isEqualToString:@""]) {
            
            NSString *taskContent = @"";
            if (![taskDescription isEqualToString:@""]) {
                taskContent = taskDescription;
            }
            if (![taskContent isEqualToString:@""]) {
                taskContent = [NSString stringWithFormat:@"%@\n%@",taskContent,taskMembers];
            }else{
                taskContent = taskMembers;
            }
            CGSize sizeTaskContent = [CommonFuntion getSizeOfContents:taskContent Font:FONT_DETAILS_CONTENT withWidth:kScreen_Width-30 withHeight:MAX_WIDTH_OR_HEIGHT];
            taskHeight += (sizeTaskContent.height+10);
        }
        
        ///分割线
        taskHeight += 1;
        taskHeight += 30;
        
        height += taskHeight;
    }
    
    ///voice
    if ([item objectForKey:@"soundUrl"]) {
        height += (40);
    }
    
    ///文件
    if ([item objectForKey:@"file"]) {
        if ([[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 0) {
            ///文件
            height += (40+10);
        }
    }
    
    if ([item objectForKey:@"recordNew"] && [[item objectForKey:@"recordNew"] objectForKey:@"ftype"]) {
        if ([[[item objectForKey:@"recordNew"] objectForKey:@"ftype"] integerValue] == 0) {
            ///文件
            height += (40+10);
        }
    }
    
    
    ///location
    NSString *location = @"";
    if ([item objectForKey:@"location"]) {
        location = [item safeObjectForKey:@"location"];
    }
    
    if (![location isEqualToString:@""]) {
        if ([[self new] isContainPic:item]) {
            height += (20+10);
        }else{
            height += (95+10);
        }
    }
    
    ///recordNew图片
    ///客户 recordNew  联系人 file
    if (([item objectForKey:@"recordNew"] && [[[item objectForKey:@"recordNew"] objectForKey:@"ftype"] integerValue] == 1 && [[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"]) || ([item objectForKey:@"file"] && [[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 1 && [[item objectForKey:@"file"] objectForKey:@"imageFiles"])) {
        
        NSArray *arrayImg;
        ///联系人
        if([item objectForKey:@"file"] && [[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 1 && [[item objectForKey:@"file"] objectForKey:@"imageFiles"]){
            arrayImg = [[item objectForKey:@"file"] objectForKey:@"imageFiles"];
        }else{
            arrayImg = [[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"];
        }
        NSInteger count = [arrayImg count];
        if (count > 0) {
            CGFloat imgHeight = [[self new] getImgViewHeight:count];
            height += (imgHeight+10);
        }
    }
    
    return height+10;
}


#pragma mark - 隐藏imageview
///隐藏全部imgview
-(void)setAllImgHide{
    self.img1.hidden = YES;
    self.img2.hidden = YES;
    self.img3.hidden = YES;
    self.img4.hidden = YES;
    self.img5.hidden = YES;
    self.img6.hidden = YES;
    self.img7.hidden = YES;
    self.img8.hidden = YES;
    self.img9.hidden = YES;
}

///根据图片个数做显示
-(void)setImgShow:(NSInteger)count{
    NSLog(@"setImgShow count:%li",count);
    if (count > 0) {
        self.img1.hidden = NO;
    }
    
    if (count > 1) {
        self.img2.hidden = NO;
    }
    
    if (count > 2) {
        self.img3.hidden = NO;
    }
    
    if (count > 3) {
        self.img4.hidden = NO;
    }
    
    if (count > 4) {
        self.img5.hidden = NO;
    }
    
    if (count > 5) {
        self.img6.hidden = NO;
    }
    
    if (count > 6) {
        self.img7.hidden = NO;
    }
    
    if (count > 7) {
        self.img8.hidden = NO;
    }
    
    if (count > 8) {
        self.img9.hidden = NO;
    }
}

///根据图片count获取图片view的height
-(CGFloat)getImgViewHeight:(NSInteger)count{
    
    CGFloat height = 0;
    if (count>9) {
        count = 9;
    }
    NSInteger line = count/3;
    if (line == 0) {
        line = 1;
    }else{
        if (count%3 !=0) {
            line += 1;
        }
    }
    
    if (line == 3) {
        height = 230;
    }else if(line == 2){
        height = 150;
    }else {
        height = 80;
    }
    
    return height;
}


#pragma mark - imageview填充图片并添加点击手势
-(void)setImageAddGestureEventForImageView:(NSDictionary *)item withIndex:(NSIndexPath *)index{
    
    if (([item objectForKey:@"recordNew"] && [[[item objectForKey:@"recordNew"] objectForKey:@"ftype"] integerValue] == 1 && [[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"]) || ([item objectForKey:@"file"] && [[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 1 && [[item objectForKey:@"file"] objectForKey:@"imageFiles"])) {
        NSArray *arrayImg;
        ///联系人
        if([item objectForKey:@"file"] && [[[item objectForKey:@"file"] objectForKey:@"type"] integerValue] == 1 && [[item objectForKey:@"file"] objectForKey:@"imageFiles"]){
            arrayImg = [[item objectForKey:@"file"] objectForKey:@"imageFiles"];
        }else{
            arrayImg = [[item objectForKey:@"recordNew"] objectForKey:@"imageFiles"];
        }
        
        
        NSInteger count = [arrayImg count];
        UITapGestureRecognizer *gesture;
        NSString *tagOfImg ;
        NSInteger imgIndex = 0;
        ///小图
        NSString *imgSizeType = @"pic";
        if (count > 0) {
            [self.img1 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:0] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
            
            gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
            tagOfImg = [NSString stringWithFormat:@"%li%li",index.row,imgIndex];
            self.img1.tag = [tagOfImg integerValue];
            [self.img1 addGestureRecognizer:gesture];
            imgIndex++;
        }
        
        if (count > 1) {
            [self.img2 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:1] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
            gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
            tagOfImg = [NSString stringWithFormat:@"%li%li",index.row,imgIndex];
            self.img2.tag = [tagOfImg integerValue];
            [self.img2 addGestureRecognizer:gesture];
            imgIndex++;
        }
        
        if (count > 2) {
            [self.img3 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:2] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
            gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
            tagOfImg = [NSString stringWithFormat:@"%li%li",index.row,imgIndex];
            self.img3.tag = [tagOfImg integerValue];
            [self.img3 addGestureRecognizer:gesture];
            imgIndex++;
        }
        
        if (count > 3) {
            [self.img4 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:3] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
            gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
            tagOfImg = [NSString stringWithFormat:@"%li%li",index.row,imgIndex];
            self.img4.tag = [tagOfImg integerValue];
            [self.img4 addGestureRecognizer:gesture];
            imgIndex++;
        }
        
        if (count > 4) {
            [self.img5 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:4] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
            gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
            tagOfImg = [NSString stringWithFormat:@"%li%li",index.row,imgIndex];
            self.img5.tag = [tagOfImg integerValue];
            [self.img5 addGestureRecognizer:gesture];
            imgIndex++;
        }
        
        if (count > 5) {
            [self.img6 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:5] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
            gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
            tagOfImg = [NSString stringWithFormat:@"%li%li",index.row,imgIndex];
            self.img6.tag = [tagOfImg integerValue];
            [self.img6 addGestureRecognizer:gesture];
            imgIndex++;
        }
        
        if (count > 6) {
            [self.img7 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:6] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
            gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
            tagOfImg = [NSString stringWithFormat:@"%li%li",index.row,imgIndex];
            self.img7.tag = [tagOfImg integerValue];
            [self.img7 addGestureRecognizer:gesture];
            imgIndex++;
        }
        
        if (count > 7) {
            [self.img8 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:7] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
            gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
            tagOfImg = [NSString stringWithFormat:@"%li%li",index.row,imgIndex];
            self.img8.tag = [tagOfImg integerValue];
            [self.img8 addGestureRecognizer:gesture];
            imgIndex++;
        }
        
        if (count > 8) {
            [self.img9 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:8] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
            gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
            tagOfImg = [NSString stringWithFormat:@"%li%li",index.row,imgIndex];
            self.img9.tag = [tagOfImg integerValue];
            [self.img9 addGestureRecognizer:gesture];
            imgIndex++;
        }
    }
}

///imageview添加点击手势、
-(void)tapHandleOfImgView:(UITapGestureRecognizer *)tap{
    UIImageView *tapImg = (UIImageView *)tap.view;
    NSString *tagIndex = [NSString stringWithFormat:@"%li",tapImg.tag];
    ///section 对应当前cell在列表中的行下标
    NSInteger section = [[tagIndex substringToIndex:tagIndex.length-1] integerValue] ;
    ///对应当前图片在cell中的下标
    NSInteger row = [[tagIndex substringFromIndex:tagIndex.length-1] integerValue] ;
    
    NSIndexPath *imgIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    NSLog(@"tapHandleOfImgView section%li  row:%li",section,row);
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickImageViewEvent:)]) {
        [self.delegate clickImageViewEvent:imgIndexPath];
    }
}


#pragma mark - cell中相关事件
///cell里控件添加事件
-(void)addClickEventForCellView:(NSIndexPath *)index{
    ///点击头像事件
    [self.btnIcon addTarget:self action:@selector(gotoPersonalInformation:) forControlEvents:UIControlEventTouchUpInside];
    self.btnIcon.tag = index.row;
    

//    __block DetailsReviewCell *mySelf = self;
//    self.labelContent.detectionBlock = ^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
//        
//        NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
//        NSLog(@"hotWord:%@",hotWords[hotWord]);
//        NSLog(@"word:%@",string);
//        
//        if (mySelf.delegate && [mySelf.delegate respondsToSelector:@selector(clickContentCharType:content:atIndex:)]) {
//            [mySelf.delegate clickContentCharType:hotWords[hotWord] content:string atIndex:index];
//        }
//    };
    
    
    ///点击语音事件
//    [self.btnVoice addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
//    self.btnVoice.tag = index.row;
    
    
    ///点击地址事件
    [self.btnAddress addTarget:self action:@selector(gotoMapView:) forControlEvents:UIControlEventTouchUpInside];
    self.btnAddress.tag = index.row;
    
    ///地址view点击事件
    UITapGestureRecognizer *gestureLocation;
    gestureLocation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfgestureLocationView:)];
    self.viewAddressContent.tag = index.row;
    [self.viewAddressContent addGestureRecognizer:gestureLocation];
    
    ///文件view点击事件
    UITapGestureRecognizer *gestureFile;
    gestureFile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfgesturegestureFile:)];
    self.viewFile.tag = index.row;
    [self.viewFile addGestureRecognizer:gestureFile];
    
}

////点击头像事件
-(void)gotoPersonalInformation:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickUserIconEvent:)]) {
        [self.delegate clickUserIconEvent:btn.tag];
    }
}

///展开全部
-(void)expContentView:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickExpContentEvent:)]) {
        [self.delegate clickExpContentEvent:btn.tag];
    }
}

///点击地址事件
-(void)gotoMapView:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickAddressEvent:)]) {
        [self.delegate clickAddressEvent:btn.tag];
    }
}

///点击语音事件
-(void)playVoice:(id)sender{
    
    /*
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickVoiceDataEvent:)]) {
        [self.delegate clickVoiceDataEvent:btn.tag];
    }
     */
    
//    NSLog(@"iteminfo:%@",itemInfo);
    
    
    
}


///点点击地址view事件
-(void)tapHandleOfgestureLocationView:(UITapGestureRecognizer *)tap{
    UIView *tapView = (UIView *)tap.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickAddressEvent:)]) {
        [self.delegate clickAddressEvent:tapView.tag];
    }
}

///点击文件view事件
-(void)tapHandleOfgesturegestureFile:(UITapGestureRecognizer *)tap{
    NSLog(@"tapHandleOfgesturegestureFile--->");
    UIView *tapView = (UIView *)tap.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickFileEvent:)]) {
        [self.delegate clickFileEvent:tapView.tag];
    }
}

@end
