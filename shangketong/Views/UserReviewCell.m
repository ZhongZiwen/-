//
//  UserReviewCell.m
//  shangketong
//
//  Created by sungoin-zjp on 15-5-25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UserReviewCell.h"
#import "AppDelegate.h"
#import "UIButton+WebCache.h"
#import "CommonConstant.h"
#import "CommonFuntion.h"
#import "User.h"

@implementation UserReviewCell

- (void)awakeFromNib {
    // Initialization code
    self.imgLine.hidden = YES;
    self.btnIcon.layer.cornerRadius = 3;
    self.btnIcon.imageView.layer.cornerRadius = 3;
    self.btnIcon.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.btnIcon.imageView.clipsToBounds = YES;
    
    self.labelName.font = FONT_WORKGROUP_NAME;
    
    self.labelContent.font = FONT_WORKGROUP_CONTENT;
    self.labelContent.textColor = [UIColor colorWithHexString:@"0x222222"];
    self.labelContent.numberOfLines = 0;
    self.labelContent.linkAttributes = kLinkAttributes;
    self.labelContent.activeLinkAttributes = kLinkAttributesActive;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/*
 
 {
 content = "@\U9648\U78ca2 @1009557451 cmmxmx";
 "createIcon " = "192.168.5.49:8080//resource/img.do?u=XDI5NFwyMDE1LTA3LTIwXDE0MzczOTY3MTY1NzUub3RoZXI=";
 createId = 377;
 createName = "\U9648\U78ca";
 date = 1437724213782;
 id = 233;
 user =                 (
 {
 name = "\U9648\U78ca2";
 uid = 378;
 },
 {
 name = 1009557451;
 uid = 379;
 }
 );
 }
 
 */


#pragma mark - 设置详情
///设置详情
-(void)setContentDetails:(NSDictionary *)item{
//        NSLog(@"item:%@",item);
    
    NSString *name = @"";
    NSString *icon = @"";
    if ([item objectForKey:@"creator"]) {
        ///姓名
        if ([[item objectForKey:@"creator"] objectForKey:@"name"]) {
            name = [[item objectForKey:@"creator"] safeObjectForKey:@"name"];
        }
        ///头像
        if ([[item objectForKey:@"creator"] objectForKey:@"icon"]) {
            icon = [[item objectForKey:@"creator"] safeObjectForKey:@"icon"];
        }
    }
    
    ///头像
    [self.btnIcon sd_setImageWithURL:[NSURL URLWithString:icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
    
    ///姓名
    CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:FONT_WORKGROUP_NAME withWidth:MAX_WIDTH_OR_HEIGHT withHeight:21];
    self.labelName.frame = CGRectMake(self.labelName.frame.origin.x, self.labelName.frame.origin.y, sizeName.width, sizeName.height);
    
    self.labelName.text = name;
    
    
    ///date
    long long date = 0;
    if ([item objectForKey:@"date"]) {
        date = [[item safeObjectForKey:@"date"] longLongValue];
    }
    
//    NSString *strDate = [CommonFuntion formateLongDateCommon:date];
    NSString *strDate = [CommonFuntion commentOrTrendsDateCommonByLong:date];
    CGSize sizeDate = [CommonFuntion getSizeOfContents:strDate Font:FONT_WORKGROUP_DATE withWidth:MAX_WIDTH_OR_HEIGHT withHeight:21];
    self.labelDate.frame = CGRectMake(self.labelDate.frame.origin.x, self.labelDate.frame.origin.y, sizeDate.width, sizeDate.height);
    self.labelDate.text = strDate;
    
    ///评论内容
    NSString *content = @"";
    if ([item objectForKey:@"content"]) {
        content = [item safeObjectForKey:@"content"];
    }

//    NSArray *userAt = nil;
//    if ([item objectForKey:@"alts"]) {
//        userAt = [item objectForKey:@"alts"];
//    }
//    
//    ///重组字符串
//    content = [CommonFuntion searchAtCharAndSetItValid:content atArray:userAt isAddressBookArray:FALSE];
    
    self.labelContent.hidden = YES;
    if (content && ![content isEqualToString:@""]) {
        self.labelContent.hidden = NO;
        
        CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_WORKGROUP_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
        
        self.labelContent.frame = CGRectMake(self.labelContent.frame.origin.x, 48, sizeContent.width, sizeContent.height);
        self.imgLine.frame = CGRectMake(15, 48+self.labelContent.frame.size.height+9, kScreen_Width, 1);
    }else{
        self.imgLine.frame = CGRectMake(15, 48, kScreen_Width, 1);
    }
    self.labelContent.text = content;
    
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
    
    ///line放置在顶部
    self.imgLine.frame = CGRectMake(10, 0, kScreen_Width, 1);
    
}


///type 类型
+(CGFloat)getCellContentHeight:(NSDictionary *)item{
    CGFloat height = 0;
    
    ///顶部40+8
    height += 48;
    
    ///content
    NSString *content = [item safeObjectForKey:@"content"];
    
//    NSString *content = @"";
//    if ([item objectForKey:@"content"]) {
//        content = [item safeObjectForKey:@"content"];
//    }
//#warning ats 改为user
//    NSArray *userAt = nil;
//    if ([item objectForKey:@"alts"]) {
//        userAt = [item objectForKey:@"alts"];
//    }
//    
//    ///重组字符串
//    content = [CommonFuntion searchAtCharAndSetItValid:content atArray:userAt isAddressBookArray:FALSE];
//    NSLog(@"content:%@",content);
    if (content && ![content isEqualToString:@""]) {
        CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_WORKGROUP_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
        
        height += (sizeContent.height+10);
    }
    
    return height;
}

/// j    js@1009557451 lkjs@陈磊2jsjsj@陈磊2@陈磊 @陈磊2 @1009557451


#pragma mark - cell中相关事件
///cell里控件添加事件
-(void)addClickEventForCellView:(NSIndexPath *)index{
    NSLog(@"addClickEventForCellView---->");
    ///点击头像事件
    [self.btnIcon addTarget:self action:@selector(gotoPersonalInformation:) forControlEvents:UIControlEventTouchUpInside];
    self.btnIcon.tag = index.section;
    
//    __block UserReviewCell *mySelf = self;
//    self.labelContent.detectionBlock = ^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
//        
//        NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
//        NSLog(@"hotWord:%@",hotWords[hotWord]);
//        NSLog(@"word:%@",string);
//        
//        if (mySelf.delegate && [mySelf.delegate respondsToSelector:@selector(clickReviewContentCharType:content:atIndex:)]) {
//            [mySelf.delegate clickReviewContentCharType:hotWords[hotWord] content:string atIndex:index];
//        }
//    };
}


///点击头像事件
-(void)gotoPersonalInformation:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickUserReviewIconEvent:)]) {
        [self.delegate clickUserReviewIconEvent:btn.tag];
    }
}

@end
