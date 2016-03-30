//
//  WorkGroupRecordCellB.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "WorkGroupRecordCellB.h"
#import "CommonFuntion.h"
#import "CommonConstant.h"
#import "CommonStaticVar.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "RecordAudioPlayView.h"
#import "User.h"
//#import "PhotoBrowser.h"
//#import "PhotoItem.h"

#define kTag_imageView 324235

@interface WorkGroupRecordCellB ()
// 音频
@property (strong, nonatomic) RecordAudioPlayView *audioView;
@property (copy, nonatomic) NSMutableArray *imagesArray;
@end

@implementation WorkGroupRecordCellB

- (void)awakeFromNib {
    // Initialization code
    self.btnIcon.layer.cornerRadius = 3;
    self.btnIcon.imageView.layer.cornerRadius = 3;
    self.btnIcon.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.btnIcon.imageView.clipsToBounds = YES;
    
    self.btnAddress.layer.cornerRadius = 3;
    self.btnAddress.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.imgFileBg.layer.cornerRadius = 2;
    
    self.btnFrom.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.labelName.font = FONT_WORKGROUP_NAME;
    self.labelActionName.font = FONT_WORKGROUP_NAME;
    self.labelContent.font = FONT_WORKGROUP_CONTENT;
    self.labelContent.textColor = [UIColor colorWithHexString:@"0x222222"];
    self.labelContent.numberOfLines = 0;
    self.labelContent.linkAttributes = kLinkAttributes;
    self.labelContent.activeLinkAttributes = kLinkAttributesActive;
    
    self.labelBlogTitle.font = FONT_WORKGROUP_BLOG_TITLE;
    self.labelBlogContent.font = FONT_WORKGROUP_BLOG_CONTENT;
    self.labelTaskContent.font = FONT_DETAILS_CONTENT;
    
    self.labelRepostName.font = FONT_WORKGROUP_NAME;
    self.labelRepostActionName.font = FONT_WORKGROUP_DATE;
    self.lableRepostContent.font = FONT_WORKGROUP_BLOG_CONTENT;
    
    
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
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithRed:242.0f/255 green:242.0f/255 blue:242.0f/255 alpha:1.0f].CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVoice) name:@"stopVoice" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - 填充详情
-(void)setContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath byCellStatus:(WorkGroupTypeStatus)cellStatus{
    
    if (!item) {
        return;
    }
    
#warning 详情页面时做显示
    self.labelReviewCount.hidden = YES;
    
#warning getTypeOfWorkGroupCellInfo 做判断   source
    ////区分是哪个页面进入的view
    [CommonStaticVar getTypeOfWorkGroupCellInfo];
    
    CGFloat yPoint = 10;
    ///头部信息
    yPoint = [self getYPointByContentIsHeadView:item andYPoint:yPoint];
    
    yPoint = 58;
    ///博文或正文信息
    yPoint = [self getYPointByContentIsBlogOrContent:item andYPoint:yPoint byCellStatus:cellStatus];
    
    if ([[item objectForKey:@"type"] integerValue] == 3) {
        NSLog(@"yPoint:%f",yPoint);
    }
    
    ///由谁完成创建等信息
    yPoint = [self getYPointByContentIsFinishBy:item andYPoint:yPoint];
    ///语音信息
    yPoint = [self getYPointByContentIsVoice:item andYPoint:yPoint isRepost:NO];
    ///文件信息
    yPoint = [self getYPointByContentIsFile:item andYPoint:yPoint];
    ///地址信息
    yPoint = [self getYPointByContentIsLocation:item andYPoint:yPoint isRepost:NO];
    ///图片
    yPoint = [self getYPointByContentIsImg:item andYPoint:yPoint isRepost:NO];
    
    self.btnRepostPriase.hidden = YES;
    self.btnRepostReview.hidden = YES;
    ///转发信息
    yPoint = [self getHeightByContentIsRepostView:item andYPoint:yPoint  byCellStatus:cellStatus];
    
    ///设置图片以及添加点击事件
    [self setImageAddGestureEventForImageView:item withIndex:indexPath];
    
    ///做为详情显示时 隐藏底部评论、转发、赞view
    ///做为详情显示时 转发内容底部的赞与评论按钮要显示(如果未被删除)
    if (cellStatus == WorkGroupTypeStatusDetails) {
        self.labelReviewCount.hidden = NO;
        self.viewOptions.hidden = YES;
        self.btnMenu.hidden = YES;
        
        self.labelReviewCount.frame = CGRectMake(self.btnIcon.frame.origin.x, yPoint, 200, 20);
        NSString *comments = @"0";
        if ([item objectForKey:@"commentCount"]) {
            comments = [NSString stringWithFormat:@"评论: %li",[[item safeObjectForKey:@"commentCount"] integerValue]];
        }
        NSString *feedUpCount = @"";
        
        if ([item objectForKey:@"feedUpCount"] && [[item safeObjectForKey:@"feedUpCount"] integerValue] > 0) {
            feedUpCount = [NSString stringWithFormat:@"赞: %li",[[item objectForKey:@"feedUpCount"] integerValue]];
        }
        self.labelReviewCount.text = [NSString stringWithFormat:@"%@ %@",comments,feedUpCount];
        
    }else{
        self.labelReviewCount.hidden = YES;
        self.viewOptions.hidden = NO;
        
        /*
        self.btnMenu.hidden = YES;
        ///更多菜单按钮
        self.btnMenu.frame = CGRectMake(kScreen_Width-50, 0, 50, 30);
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"moduleType"]]) {
            if ([[item objectForKey:@"moduleType"] integerValue] == 1 || [[item objectForKey:@"moduleType"] integerValue] == 2) {
                self.btnMenu.hidden = NO;
            }
        }
         */
        
        self.viewOptions.frame = CGRectMake(0, yPoint+10, kScreen_Width, 40);
        
        self.btnRepostPriase.hidden = YES;
        self.btnRepostReview.hidden = YES;
    }
    self.viewOptions.layer.borderColor = [UIColor colorWithRed:242.0f/255 green:242.0f/255 blue:242.0f/255 alpha:1.0f].CGColor;
    self.viewOptions.layer.borderWidth = 0.5;
    
    ///底部view
    [self setBottomOptionView:item];
    
    ///作为cell展示时
    if (cellStatus == WorkGroupTypeStatusCell) {
        ///@我的信息
        yPoint = [self getHeightByMsgViewContent:item andYPoint:yPoint];
        ///commentFrom
        NSDictionary *source = nil;
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"commentFrom"]])  {
            source = [item objectForKey:@"commentFrom"];
        }
        
        if (source) {
            self.viewOptions.hidden = YES;
            self.btnMenu.hidden = YES;
        }
    }
    
}


///设置底部按钮详情  转发 、评论、赞
-(void)setBottomOptionView:(NSDictionary *)item{
    BOOL isCanRepost = FALSE;
    BOOL isCanReview = FALSE;
    BOOL isCanPraise = FALSE;
    
    self.btnRepost.hidden = YES;
    self.btnReview.hidden = YES;
    self.btnPraise.hidden = YES;
    
#warning 测试
    ///是否可转发
    if ([[item safeObjectForKey:@"canForward"] integerValue] == 0) {
        isCanRepost = TRUE;
        self.btnRepost.hidden = NO;
    }
    
    ///可转发
    if (isCanRepost) {
        ///转发数量
        NSString *feedForwardCount = @" 转发";
        if ([[item safeObjectForKey:@"feedForwardCount"] integerValue] > 0) {
            feedForwardCount = [NSString stringWithFormat:@"% li",[[item safeObjectForKey:@"feedForwardCount"] integerValue]];
        }
        [self.btnRepost setTitle:feedForwardCount forState:UIControlStateNormal];
    }
    
    
    
    ///是否可评论
    isCanReview = TRUE;
    self.btnReview.hidden = NO;
    ///可评论
    if (isCanReview) {
        ///评论数量
        NSString *comments = @" 评论";
        if ([[item safeObjectForKey:@"commentCount"] integerValue] > 0) {
            comments = [NSString stringWithFormat:@"% li",[[item safeObjectForKey:@"commentCount"] integerValue]];
        }
        [self.btnReview setTitle:comments forState:UIControlStateNormal];
    }
    
    
    ///是否可赞
    isCanPraise = FALSE;
    self.btnPraise.hidden = YES;
    NSInteger system = [[item safeObjectForKey:@"system"] integerValue];
    
    if (system == 607) {
        isCanPraise = FALSE;
    }else{
        isCanPraise = TRUE;
    }
    
    ///可以赞
    if (isCanPraise) {
        self.btnPraise.hidden = NO;
        ///赞
        NSString *feedUpCount = @" 赞";
        if ([[item safeObjectForKey:@"feedUpCount"] integerValue] > 0) {
            feedUpCount = [NSString stringWithFormat:@" %li",[[item safeObjectForKey:@"feedUpCount"] integerValue]];
        }
        [self.btnPraise setTitle:feedUpCount forState:UIControlStateNormal];
        
        
        ///是否已经赞
        NSInteger  isFeedUp = [[item safeObjectForKey:@"isFeedUp"] integerValue];
//        if ([item objectForKey:@"isFeedUp"]) {
//            isFeedUp = [[item safeObjectForKey:@"isFeedUp"] integerValue];
//        }
        
        ///还没有赞
        if (isFeedUp == 1) {
            [self.btnPraise setImage:[UIImage imageNamed:@"feed_praise.png"] forState:UIControlStateNormal];
            //        self.btnPraise.userInteractionEnabled = YES;
        }else{
            [self.btnPraise setImage:[UIImage imageNamed:@"feed_praise_select.png"] forState:UIControlStateNormal];
            //        self.btnPraise.userInteractionEnabled = NO;
        }
    }
    
    CGFloat width = 0;
    CGFloat height = 40.0;
    
    if ([[item objectForKey:@"moduleType"] integerValue] == 2) {
        self.btnRepost.hidden = YES;
        self.btnPraise.hidden = YES;
        
        width = kScreen_Width/3;
        self.btnReview.frame = CGRectMake(width*2, 0, width, height);
    }else{
        ///三个按钮
        if (isCanRepost && isCanReview && isCanPraise) {
            width = kScreen_Width/3;
            self.btnRepost.frame = CGRectMake(0, 0, width, height);
            self.btnReview.frame = CGRectMake(width, 0, width, height);
            self.btnPraise.frame = CGRectMake(width*2, 0, width, height);
        }else if (isCanReview && isCanPraise){
            width = kScreen_Width/2;
            self.btnReview.frame = CGRectMake(0, 0, width, height);
            self.btnPraise.frame = CGRectMake(width, 0, width, height);
        }else if(isCanReview){
            width = kScreen_Width/3;
            self.btnReview.frame = CGRectMake(width*2, 0, width, height);
        }
    }
    
    
    
}


#pragma mark  头部view  头像姓名等
-(CGFloat)getYPointByContentIsHeadView:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    ///user
    NSDictionary *user = nil;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"user"]]) {
        user = [item objectForKey:@"user"];
    }else if ([CommonFuntion checkNullForValue:[item objectForKey:@"creator"]]) {
        user = [item objectForKey:@"creator"];
    }
    
    NSString *name = @"";
    NSString *icon = @"";
    NSString *uid = @"";
    if (user) {
        ///姓名
        if ([user objectForKey:@"name"]) {
            name = [user safeObjectForKey:@"name"];
        }
        ///头像
        if ([user objectForKey:@"icon"]) {
            icon = [user safeObjectForKey:@"icon"];
        }
        
        ///UID
        if ([user objectForKey:@"id"]) {
            uid = [user safeObjectForKey:@"id"];
        }
    }
    
    
    
    self.btnIcon.frame = CGRectMake(10, yPoint, 30, 30);
    
    [self.btnIcon sd_setImageWithURL:[NSURL URLWithString:icon] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
    
    CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:FONT_WORKGROUP_NAME withWidth:kScreen_Width-100 withHeight:20];
    self.labelName.frame = CGRectMake(50, 7, sizeName.width, 20);
    self.labelName.text = name;
    
#warning 待调试
    ///所属行为
    self.viewAction.hidden = YES;
    
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"activiyRecord"]]) {
        if ([item objectForKey:@"activiyRecord"]  && [[item objectForKey:@"activiyRecord"] objectForKey:@"name"]) {
            self.viewAction.hidden = NO;
            NSString *typeName = [[item objectForKey:@"activiyRecord"] safeObjectForKey:@"name"];
            CGSize sizeTypeName = [CommonFuntion getSizeOfContents:typeName Font:FONT_WORKGROUP_NAME withWidth:kScreen_Width-100 withHeight:20];
            self.viewAction.frame = CGRectMake(self.labelName.frame.origin.x+sizeName.width+5, self.labelName.frame.origin.y, sizeTypeName.width+15, 21);
            
            self.labelActionName.text = typeName;
        }
    }
    
    self.btnMenu.hidden = YES;
    ///更多菜单按钮
    self.btnMenu.frame = CGRectMake(kScreen_Width-50, 0, 50, 30);
    if ([[item objectForKey:@"moduleType"] integerValue] == 1 ) {
        self.btnMenu.hidden = NO;
    }else if([[item objectForKey:@"moduleType"] integerValue] == 2){
        ///CRM活动记录 是当前用户的话则显示更多操作按钮
        if ([appDelegateAccessor.moudle.userId longLongValue] == [uid longLongValue]) {
            self.btnMenu.hidden = NO;
        }
    }
    
    ///系统自动生成的动态  type 3 博文  1 发布  2 转发
    //    if ([item objectForKey:@"type"] && [[item safeObjectForKey:@"type"] integerValue] == 3) {
    //        self.btnMenu.hidden = YES;
    //    }
    
    ///date
    long long date = 0;
    if ([item objectForKey:@"created"]) {
        date = [[item safeObjectForKey:@"created"] longLongValue];
    }else if ([item objectForKey:@"date"]) {
        date = [[item safeObjectForKey:@"date"] longLongValue];
    }
    
    /*
    //修改显示时间格式问题 ----蒋晓飞
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSince1970:date/1000.0];
    NSString *strDate = [CommonFuntion transDateWithFormatDate:newDate];
     */
    NSString *strDate = [CommonFuntion commentOrTrendsDateCommonByLong:date];
    
    CGSize sizeDate = [CommonFuntion getSizeOfContents:strDate Font:FONT_WORKGROUP_DATE withWidth:MAX_WIDTH_OR_HEIGHT withHeight:20];
    self.labelDate.frame = CGRectMake(50, 25, sizeDate.width, 20);
    self.labelDate.text = strDate;
    
    //    NSLog(@"created:%@",[CommonFuntion transDateWithTimeInterval:date withFormat:DATE_FORMAT_MMddHHmm]);
    
    ///from
    NSDictionary *from = nil;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"from"]]) {
        from = [item objectForKey:@"from"];
    }
    
    NSString *fromname = @"";
    NSString *frombelongName = @"";
    if (from) {
        if ([from objectForKey:@"name"]) {
            fromname = [from safeObjectForKey:@"name"];
        }
        if ([from objectForKey:@"sourceName"]) {
            frombelongName = [from safeObjectForKey:@"sourceName"];
        }
    }
    
    self.btnFrom.hidden = YES;
    if (![frombelongName isEqualToString:@""]) {
        self.btnFrom.hidden = NO;
        NSString *belongContent = [NSString stringWithFormat:@"来自%@ (%@)",frombelongName,fromname];
        CGSize sizeBelongContent = [CommonFuntion getSizeOfContents:belongContent Font:[UIFont systemFontOfSize:11.0] withWidth:kScreen_Width-150 withHeight:20];
        
        self.btnFrom.frame = CGRectMake(self.labelDate.frame.origin.x+sizeDate.width+5, 25, sizeBelongContent.width, 20);
        [self.btnFrom setTitle:belongContent forState:UIControlStateNormal];
        
    }
    return newYPoint;
}

#pragma mark  是否有blog或者正文content  是则计算其高度并返回
-(CGFloat)getYPointByContentIsBlogOrContent:(NSDictionary *)item andYPoint:(CGFloat)yPoint byCellStatus:(WorkGroupTypeStatus)cellStatus{
    CGFloat newYPoint = yPoint;
    
    self.imgPraiseIcon.hidden = YES;
    ///如果存在blog  则不显示content
    self.btnExpContent.hidden = YES;
    self.btnBlogExp.hidden = YES;
    self.labelContent.hidden = YES;
    self.viewBlog.hidden = YES;
    self.viewBlog.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewBlog.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewBlog];
    
    ///blog
    NSDictionary *blog = item;
    //    if ([item objectForKey:@"blog"]) {
    //        blog = [item objectForKey:@"blog"];
    //    }
    //    NSLog(@"1122item:%@",item);
    //    NSLog(@"type:%ti",[[item objectForKey:@"type"] integerValue]);
    
    NSInteger type = 0;
    if ([item objectForKey:@"type"]) {
        type = [[item safeObjectForKey:@"type"] integerValue];
    }
    if (type != 1 && type !=2 && type != 3) {
        type = 0;
    }
    
    ///是博文
    if (type == 3) {
        CGFloat blogHeight = 0;
        self.btnBlogExp.hidden = YES;
        self.viewBlog.hidden = NO;
        NSString *blogtitle = @"";
        NSString *blogcontent = @"";
        
        ///详情则需要显示content  需显示title
        if (cellStatus == WorkGroupTypeStatusDetails) {
            self.labelBlogTitle.hidden = NO;
            ///标题
            if ([blog objectForKey:@"blogTitle"]) {
                blogtitle = [blog safeObjectForKey:@"blogTitle"];
            }
            
            CGSize sizeBlogTtile = [CommonFuntion getSizeOfContents:blogtitle Font:FONT_WORKGROUP_BLOG_TITLE withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
            
            
            if (![blogtitle isEqualToString:@""]) {
                blogHeight += (sizeBlogTtile.height+10);
            }
            
            self.labelBlogTitle.frame = CGRectMake(0, 0, kScreen_Width-20, sizeBlogTtile.height);
            self.labelBlogTitle.text = blogtitle;
            
            
            ///内容
            if ([blog objectForKey:@"content"]) {
                blogcontent = [blog safeObjectForKey:@"content"];
            }
            
            self.btnBlogExp.hidden = YES;
            self.labelBlogContent.hidden = YES;
            if (![blogcontent isEqualToString:@""]) {
                self.labelBlogContent.hidden = NO;
                
                //                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[blogcontent dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                //
                //                NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
                
                //              CGSize sizeBlogContent =  [attS boundingRectWithSize:CGSizeMake(kScreen_Width-20, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
                
                CGSize sizeBlogContent = [CommonFuntion getSizeOfContents:blogcontent Font:FONT_WORKGROUP_BLOG_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
                
                //                CGSize sizeBlogContent = [CommonFuntion getSizeOfContents:blogcontent Font:FONT_WORKGROUP_BLOG_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
                //           CGFloat heightBlog1 =   [self heightForAttributedString:blogcontent Font:FONT_WORKGROUP_BLOG_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
                //            NSLog(@"heightBlog1:%f",heightBlog1);
                //            CGFloat heightBlog2 =   [self getAttributedStringHeightWithString:blogcontent Font:FONT_WORKGROUP_BLOG_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
                //            NSLog(@"heightBlog2:%f",heightBlog2);
                
                ///已经处于展开状态
                if ([item objectForKey:@"isExp"] && [[item objectForKey:@"isExp"] isEqualToString:@"yes"]) {
                    self.btnBlogExp.hidden = NO;
                    [self.btnBlogExp setTitle:@"收起" forState:UIControlStateNormal];
                }else{
                    [self.btnBlogExp setTitle:@"展开全部" forState:UIControlStateNormal];
                    if (sizeBlogContent.height > 130) {
                        self.btnBlogExp.hidden = NO;
                        sizeBlogContent.height = 130;
                    }else{
                        self.btnBlogExp.hidden = YES;
                    }
                }
                
                self.labelBlogContent.frame = CGRectMake(0, blogHeight, kScreen_Width-20, sizeBlogContent.height);
                
                
                
                self.labelBlogContent.text = blogcontent;
                
                blogHeight += (sizeBlogContent.height+10);
                
                self.btnBlogExp.frame = CGRectMake(self.labelBlogContent.frame.origin.x, blogHeight, 150, 20);
                
                if (!self.btnBlogExp.isHidden) {
                    blogHeight += (20+10);
                }
                self.viewBlog.frame = CGRectMake(10, yPoint, kScreen_Width-20, blogHeight);
            }
            newYPoint += blogHeight;
        }else{
            self.labelBlogTitle.hidden = NO;
            self.labelBlogContent.hidden = YES;
            self.btnBlogExp.hidden = YES;
            ///标题
            if ([blog objectForKey:@"blogTitle"]) {
                blogtitle = [blog safeObjectForKey:@"blogTitle"];
            }
            blogtitle = [NSString stringWithFormat:@"我发布了一篇博文:%@",blogtitle];
            
            blogHeight += (20+20);
            
            self.labelBlogTitle.frame = CGRectMake(0, 0, kScreen_Width-20, 20);
            self.labelBlogTitle.text = blogtitle;
            
            self.viewBlog.frame = CGRectMake(10, yPoint, kScreen_Width-20, blogHeight);
            newYPoint += blogHeight;
        }
        
    }else{
        CGFloat praiseWidth = 0;
        ///praise 图标
        NSString *praiseIconName = @"";
        if ([item objectForKey:@"praise"]) {
            praiseIconName = [self getIconByLogoValue:[[[item objectForKey:@"praise"] safeObjectForKey:@"logo"] integerValue]];
        }
        
        if (![praiseIconName isEqualToString:@""]) {
            self.imgPraiseIcon.hidden = NO;
            self.imgPraiseIcon.frame = CGRectMake(10, yPoint-5, 25, 31);
            self.imgPraiseIcon.image = [UIImage imageNamed:praiseIconName];
            praiseWidth = 30;
        }
        
        ///content
        NSString *content = item[@"content"];

//        NSString *content = @"";
//        if ([item safeObjectForKey:@"content"]) {
//            content = [NSString stringWithFormat:@"%@    ",[item objectForKey:@"content"]];
//        }
//        
//        
//        NSArray *userAt = nil;
//        if ([item objectForKey:@"alts"]) {
//            userAt = [item objectForKey:@"alts"];
//        }
//        
//        ///重组字符串
//        content = [CommonFuntion searchAtCharAndSetItValid:content atArray:userAt isAddressBookArray:FALSE];
        
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            // 处理耗时操作的代码块...
//            
//            
//            //通知主线程刷新
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //回调或者说是通知主线程刷新， 
//            }); 
//            
//        });
        
        
#warning 展开按钮
        self.btnExpContent.hidden = YES;
        self.labelContent.hidden = YES;
        if (![content isEqualToString:@""]) {
            self.labelContent.hidden = NO;
            CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_WORKGROUP_CONTENT withWidth:kScreen_Width-20-praiseWidth withHeight:MAX_WIDTH_OR_HEIGHT];
            
            ///已经处于展开状态
            if ([item objectForKey:@"isExp"] && [[item objectForKey:@"isExp"] isEqualToString:@"yes"]) {
                self.btnExpContent.hidden = NO;
                [self.btnExpContent setTitle:@"收起" forState:UIControlStateNormal];
            }else{
                [self.btnExpContent setTitle:@"展开全部" forState:UIControlStateNormal];
                if (sizeContent.height > 130) {
                    self.btnExpContent.hidden = NO;
                    sizeContent.height = 130;
                }else{
                    self.btnExpContent.hidden = YES;
                }
            }
            
            self.labelContent.frame = CGRectMake(10+praiseWidth, yPoint, kScreen_Width-20-praiseWidth, sizeContent.height+10);
            self.labelContent.text = content;
            
            //添加长按手势 ----蒋晓飞
            //            UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(copyContent:)];
            //            [self.labelContent addGestureRecognizer:longGest];
            
            newYPoint += (sizeContent.height+10);
            
            self.btnExpContent.frame = CGRectMake(self.labelContent.frame.origin.x, newYPoint, 150, 20);
            
            if (!self.btnExpContent.isHidden) {
                newYPoint += (20+10);
            }
        }
    }
    
    /*
     if (blog) {
     CGFloat blogHeight = 0;
     self.btnBlogExp.hidden = YES;
     self.viewBlog.hidden = NO;
     NSString *blogtitle = @"";
     NSString *blogcontent = @"";
     ///标题
     if ([blog objectForKey:@"title"]) {
     blogtitle = [blog safeObjectForKey:@"title"];
     }
     
     if (![blogtitle isEqualToString:@""]) {
     blogHeight += (20+10);
     }
     
     self.labelBlogTitle.frame = CGRectMake(0, 0, kScreen_Width-20, 20);
     self.labelBlogTitle.text = blogtitle;
     
     
     ///内容
     if ([blog objectForKey:@"content"]) {
     blogcontent = [blog safeObjectForKey:@"content"];
     }
     
     self.btnBlogExp.hidden = YES;
     self.labelBlogContent.hidden = YES;
     if (![blogcontent isEqualToString:@""]) {
     self.labelBlogContent.hidden = NO;
     CGSize sizeBlogContent = [CommonFuntion getSizeOfContents:blogcontent Font:FONT_WORKGROUP_BLOG_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
     
     ///已经处于展开状态
     if ([item objectForKey:@"isExp"] && [[item objectForKey:@"isExp"] isEqualToString:@"yes"]) {
     self.btnBlogExp.hidden = NO;
     [self.btnBlogExp setTitle:@"收起" forState:UIControlStateNormal];
     }else{
     [self.btnBlogExp setTitle:@"展开全部" forState:UIControlStateNormal];
     if (sizeBlogContent.height > 130) {
     self.btnBlogExp.hidden = NO;
     sizeBlogContent.height = 130;
     }else{
     self.btnBlogExp.hidden = YES;
     }
     }
     
     self.labelBlogContent.frame = CGRectMake(0, 30, kScreen_Width-20, sizeBlogContent.height);
     self.labelBlogContent.text = blogcontent;
     
     blogHeight += (sizeBlogContent.height+10);
     
     self.btnBlogExp.frame = CGRectMake(self.labelBlogContent.frame.origin.x, blogHeight, 150, 20);
     
     if (!self.btnBlogExp.isHidden) {
     blogHeight += (20+10);
     }
     self.viewBlog.frame = CGRectMake(10, yPoint, kScreen_Width-20, blogHeight);
     
     newYPoint += blogHeight;
     }
     
     }else{
     CGFloat praiseWidth = 0;
     ///praise 图标
     NSString *praiseIconName = @"";
     if ([item objectForKey:@"praise"]) {
     praiseIconName = [self getIconByLogoValue:[[[item objectForKey:@"praise"] safeObjectForKey:@"logo"] integerValue]];
     }
     
     if (![praiseIconName isEqualToString:@""]) {
     self.imgPraiseIcon.hidden = NO;
     self.imgPraiseIcon.frame = CGRectMake(10, yPoint-5, 25, 31);
     self.imgPraiseIcon.image = [UIImage imageNamed:praiseIconName];
     praiseWidth = 30;
     }
     
     ///content
     NSString *content = @"";
     if ([item safeObjectForKey:@"content"]) {
     content = [NSString stringWithFormat:@"%@    ",[item objectForKey:@"content"]];
     }
     
     
     NSArray *userAt = nil;
     if ([item objectForKey:@"alts"]) {
     userAt = [item objectForKey:@"alts"];
     }
     
     ///重组字符串
     content = [CommonFuntion searchAtCharAndSetItValid:content atArray:userAt isAddressBookArray:FALSE];
     
     
     #warning 展开按钮
     self.btnExpContent.hidden = YES;
     self.labelContent.hidden = YES;
     if (![content isEqualToString:@""]) {
     self.labelContent.hidden = NO;
     CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_WORKGROUP_CONTENT withWidth:kScreen_Width-20-praiseWidth withHeight:MAX_WIDTH_OR_HEIGHT];
     
     ///已经处于展开状态
     if ([item objectForKey:@"isExp"] && [[item objectForKey:@"isExp"] isEqualToString:@"yes"]) {
     self.btnExpContent.hidden = NO;
     [self.btnExpContent setTitle:@"收起" forState:UIControlStateNormal];
     }else{
     [self.btnExpContent setTitle:@"展开全部" forState:UIControlStateNormal];
     if (sizeContent.height > 130) {
     self.btnExpContent.hidden = NO;
     sizeContent.height = 130;
     }else{
     self.btnExpContent.hidden = YES;
     }
     }
     
     self.labelContent.frame = CGRectMake(10+praiseWidth, yPoint, kScreen_Width-20-praiseWidth, sizeContent.height+10);
     self.labelContent.text = content;
     //添加长按手势 ----蒋晓飞
     //            UILongPressGestureRecognizer *longGest = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(copyContent:)];
     //            [self.labelContent addGestureRecognizer:longGest];
     
     newYPoint += (sizeContent.height+10);
     
     self.btnExpContent.frame = CGRectMake(self.labelContent.frame.origin.x, newYPoint, 150, 20);
     
     if (!self.btnExpContent.isHidden) {
     newYPoint += (20+10);
     }
     }
     //        NSLog(@"content:%@",content);
     }
     */
    return newYPoint;
}
- (void)copyContent:(UILongPressGestureRecognizer *)longGest {
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyHandleAction:)];
    UIMenuController *controller = [UIMenuController sharedMenuController];
    [controller setMenuItems:[NSArray arrayWithObjects:copyItem, nil]];
    [controller setTargetRect:longGest.view.frame inView:self];
    [controller setMenuVisible:YES animated:YES];
}
- (void)copyHandleAction:(id)sender {
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    //    board.string = _chatMsgModel.msg_content;
}

#pragma mark  是否有谁创建完成之类内容  是则计算其高度并返回
-(CGFloat)getYPointByContentIsFinishBy:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = 0;
    ///该任务由谁创建完成之类
    self.labelTaskContent.hidden = YES;
    self.labelFinishBy.hidden = YES;
    
    
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"recordNew"]]) {
        if ([item objectForKey:@"recordNew"]  && [[item objectForKey:@"recordNew"] objectForKey:@"taskCreatedBy"]) {
            self.labelTaskContent.hidden = NO;
            self.labelFinishBy.hidden = NO;
            
            
            NSDictionary *itemTask = [item objectForKey:@"recordNew"];
            ///任务描述
            NSString *taskDescription = @"";
            if ([itemTask objectForKey:@"taskDescription"]) {
                taskDescription = [itemTask safeObjectForKey:@"taskDescription"];
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
                
                //            NSLog(@"taskDescription:%@",taskDescription);
                //            NSLog(@"taskMembers:%@",taskMembers);
                NSString *taskContent = @"";
                if (![taskDescription isEqualToString:@""]) {
                    taskContent = taskDescription;
                }
                if (![taskContent isEqualToString:@""]) {
                    taskContent = [NSString stringWithFormat:@"%@\n%@",taskContent,taskMembers];
                }else{
                    taskContent = taskMembers;
                }
                //            NSLog(@"taskContent:%@",taskContent);
                CGSize sizeTaskContent = [CommonFuntion getSizeOfContents:taskContent Font:FONT_DETAILS_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
                self.labelTaskContent.frame = CGRectMake(10, yPoint, sizeTaskContent.width, sizeTaskContent.height);
                self.labelTaskContent.text = taskContent;
                
                newYPoint += (sizeTaskContent.height+10);
            }else{
                self.labelTaskContent.frame = CGRectMake(5, 0, 0, 0);
                self.labelTaskContent.hidden = YES;
            }
            
            
            NSString *taskCreatedBy = @"";
            if ([[[item objectForKey:@"recordNew"] objectForKey:@"taskCreatedBy"] objectForKey:@"name"]) {
                taskCreatedBy = [[[item objectForKey:@"recordNew"] objectForKey:@"taskCreatedBy"] safeObjectForKey:@"name"];
            }
            
            ///date
            long long taskCreatedAt = 0;
            if ([[item objectForKey:@"recordNew"] objectForKey:@"taskCreatedAt"]) {
                taskCreatedAt = [[[item objectForKey:@"recordNew"] safeObjectForKey:@"taskCreatedAt"] longLongValue];
            }
            self.labelFinishBy.frame = CGRectMake(10, newYPoint+yPoint, kScreen_Width-20, 20);
            self.labelFinishBy.text = [NSString stringWithFormat:@"该任务于%@ 由%@创建",[CommonFuntion transDateWithTimeInterval:taskCreatedAt withFormat:DATE_FORMAT_yyyyMMddHHmm],taskCreatedBy];
            
            newYPoint += (20+10);
        }
    }
    
    
    return newYPoint+yPoint;
}

#pragma mark  是否有语音内容  是则计算其高度并返回
-(CGFloat)getYPointByContentIsVoice:(NSDictionary *)item andYPoint:(CGFloat)yPoint isRepost:(BOOL)isRepost{
    CGFloat newYPoint = yPoint;
    [_audioView removeFromSuperview];
    NSString *soundUrl = @"";
    //区分OA（1） CRM（2） ----蒋晓飞
//    if ([[item objectForKey:@"moduleType"] integerValue] == 2) {
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"audio"]]) {
            
            if ([[item objectForKey:@"audio"] objectForKey:@"url"]) {
                soundUrl = [[item objectForKey:@"audio"] safeObjectForKey:@"url"];
            }
            
            if (soundUrl && soundUrl.length > 0) {
                if (isRepost) {
                    [self.viewRepost addSubview:self.audioView];
                }else{
                    [self addSubview:self.audioView];
                }
                
                self.audioView.frame = CGRectMake(10, yPoint, 100, 40);
                _audioView.second = [NSNumber numberWithLong:[[[item objectForKey:@"audio"] objectForKey:@"second"] longValue]];
                [_audioView setUrl:[NSURL URLWithString:soundUrl]];
                newYPoint += (40+10);
            }
            
            
        }
//    }
    
    /*
    ///sound
    self.viewVoice.hidden = YES;
    self.viewVoice.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewVoice.backgroundColor = [UIColor clearColor];
    if (isRepost) {
        [self.viewRepost addSubview:self.viewVoice];
    }else{
        [self addSubview:self.viewVoice];
    }
    
    NSString *soundUrl = @"";
    //区分OA（1） CRM（2） ----蒋晓飞
    if ([[item objectForKey:@"moduleType"] integerValue] == 2) {
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"audio"]]) {
            self.viewVoice.hidden = NO;
            if ([[item objectForKey:@"audio"] objectForKey:@"url"]) {
                soundUrl = [[item objectForKey:@"audio"] safeObjectForKey:@"url"];
            }
            NSString *soundDuration = @"";
            if ([[item objectForKey:@"audio"] objectForKey:@"second"]) {
                soundDuration = [NSString stringWithFormat:@"%li''",[[[item objectForKey:@"audio"] objectForKey:@"second"] integerValue] / 1000];
            }
            self.viewVoice.frame = CGRectMake(10, yPoint, 100, 40);
            self.labelVoiceDuration.text = soundDuration;
            newYPoint += (40+10);
        }
    }
     */
    
    return newYPoint;
}

- (RecordAudioPlayView*)audioView {
    if (!_audioView) {
        _audioView = [[RecordAudioPlayView alloc] init];
        [_audioView setX:10];
    }
    return _audioView;
}

- (void)stopVoice {
    [_audioView stop];
}

#pragma mark  是否有文件内容  是则计算其高度并返回
-(CGFloat)getYPointByContentIsFile:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    
    self.viewFile.hidden = YES;
    self.viewFile.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewFile.backgroundColor = [UIColor clearColor];
    self.imgFileBg.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:240.0f/255 green:240.0f/255 blue:240.0f/255 alpha:1.0f]];
    
    
    [self addSubview:self.viewFile];
    
#warning type判断
    ///fileType  0 不存在  1图片  2附件
    ///file
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"file"]] && [item objectForKey:@"fileType"]) {
        if ([[item safeObjectForKey:@"fileType"]  integerValue] == 2) {
            ///文件
            self.viewFile.hidden = NO;
            self.viewFile.frame = CGRectMake(10, yPoint, kScreen_Width-20, 40);
            self.imgFileBg.frame = CGRectMake(0, 0, kScreen_Width-20, 40);
            
            
            NSString *filename = @"";
            if ([[item objectForKey:@"file"] objectForKey:@"name"]) {
                filename = [[item objectForKey:@"file"] safeObjectForKey:@"name"];
            }
            self.labelFileName.text = filename;
            self.labelFileName.frame = CGRectMake(35, 10, kScreen_Width-65, 20);
            
            
            
            newYPoint += (40+10);
        }
    }
    return newYPoint;
}

#pragma mark  是否有地址内容  是则计算其高度并返回
-(CGFloat)getYPointByContentIsLocation:(NSDictionary *)item andYPoint:(CGFloat)yPoint isRepost:(BOOL)isRepost{
    CGFloat newYPoint = yPoint;
    ///position
    NSString *position = @"";
    if ([item objectForKey:@"position"]) {
        position = [item safeObjectForKey:@"position"];
    }
    NSString *locationDetail = @"";
    if ([item objectForKey:@"position"]) {
        locationDetail = [item safeObjectForKey:@"position"];
    }
    
    
    double  latitude = 0;
    double  longitude = 0;
    if ([item objectForKey:@"latitude"]) {
        latitude = [[item safeObjectForKey:@"latitude"] doubleValue];
    }
    if ([item objectForKey:@"longitude"]) {
        longitude = [[item safeObjectForKey:@"longitude"] doubleValue];
    }
    
    self.viewAddress.hidden = YES;
    self.viewAddress.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewAddress.backgroundColor = [UIColor clearColor];
    
    CGFloat width = 0;
    CGFloat xPoint = 0;
    if (isRepost) {
        width = kScreen_Width - 30;
        xPoint = 5;
        [self.viewRepost addSubview:self.viewAddress];
    }else{
        width = kScreen_Width - 20;
        [self addSubview:self.viewAddress];
    }
    
    if (![position isEqualToString:@""] && latitude !=0 && longitude !=0) {
        self.viewAddress.hidden = NO;
        
        //        NSLog(@"location:%@",position);
        [self.btnAddress setTitle:position forState:UIControlStateNormal];
        self.labelAddress.text = locationDetail;
        self.labelAddressStreet.text = position;
        
        self.btnAddress.imageEdgeInsets = UIEdgeInsetsMake(0,-5,0,0);//设置image在button上的位置（上top，左left，下bottom，右right）这里可以写负值，对上写－5，那么image就象上移动5个像素
        
        
        if ([self isContainPic:item]) {
            self.viewAddress.frame = CGRectMake(5+xPoint, yPoint+3, width, 20);
            newYPoint += (20+10);
            self.viewAddressContent.hidden = YES;
        }else{
            self.viewAddress.frame = CGRectMake(5+xPoint, yPoint, width, 85);
            self.viewAddressContent.frame = CGRectMake(5, 20, width, 65);
            self.imgAddressBg.frame = CGRectMake(0, 0, width, 65);
            self.imgAddressBg.image = [CommonFuntion createImageWithColor:VIEW_BG_COLOR];
            newYPoint += (85+10);
            self.viewAddressContent.hidden = NO;
        }
    }
    return newYPoint;
}

///判断是否包含图片
-(BOOL)isContainPic:(NSDictionary *)item{
    BOOL isContain = FALSE;
    /// fileType  0 不存在  1图片  2附件
    /// imageFiles 判断图片
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"imageFiles"]] && [item objectForKey:@"fileType"]) {
        if ([[item safeObjectForKey:@"fileType"]  integerValue] == 1) {
            if ([[item objectForKey:@"imageFiles"] count] > 0) {
                isContain = TRUE;
            }
        }
    }
    return isContain;
}

#pragma mark  是否有图片内容  是则计算其高度并返回
-(CGFloat)getYPointByContentIsImg:(NSDictionary *)item andYPoint:(CGFloat)yPoint isRepost:(BOOL)isRepost{
    CGFloat newYPoint = yPoint;
    self.viewImage.hidden = YES;
    self.viewImage.frame = CGRectMake(10, yPoint, 0, 0);
    //    self.viewImage.backgroundColor = [UIColor clearColor];
    
    
    ///判断是转发还是正常动态
    if (isRepost) {
        //        item = [item objectForKey:@"forward"];
        [self.viewRepost addSubview:self.viewImage];
    }else{
        [self addSubview:self.viewImage];
    }
    
    ///图片recordNew
    [self setAllImgHide];
    //    self.viewImage.hidden = YES;
    /// fileType  0 不存在  1图片  2附件
    /// imageFiles 判断图片
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"imageFiles"]] && [item objectForKey:@"fileType"]) {
        if ([[item safeObjectForKey:@"fileType"]  integerValue] == 1) {
            NSArray *arrayImg = [item objectForKey:@"imageFiles"];
            
            NSInteger count = [arrayImg count];
            if (count > 0) {
                self.viewImage.hidden = NO;
                [self setImgShow:count];
                //                NSLog(@"imgCount:%li",count);
                CGFloat imgHeight = [self getImgViewHeight:count];
                self.viewImage.frame = CGRectMake(10, yPoint, 230, imgHeight);
                newYPoint += (imgHeight+10);
                if (isRepost) {
                    newYPoint -= 10;
                }
            }
        }
        
    }
    
    return newYPoint;
}

#pragma mark  是否有转发内容  是则计算其高度并返回
-(CGFloat)getHeightByContentIsRepostView:(NSDictionary *)item andYPoint:(CGFloat)yPoint byCellStatus:(WorkGroupTypeStatus)cellStatus{
    CGFloat newYPoint = yPoint;
    self.viewRepost.hidden = YES;
    self.viewRepost.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewRepost.backgroundColor = [UIColor clearColor];
    [self addSubview:self.viewRepost];
    
    ///是转发信息
    if ([[item objectForKey:@"type"] integerValue] == 2) {
        ///
        NSDictionary *feedItem = nil;
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            feedItem = [item objectForKey:@"forward"];
        }
        
        CGFloat newYPointRepost = 0;
        ///有转发内容
        if (feedItem) {
            
            self.labelRepostName.hidden = NO;
            self.viewRepostAction.hidden = NO;
            //            NSLog(@"有转发内容...");
            self.viewRepost.hidden = NO;
            ///头部内容
            newYPointRepost = [self getHeightByContentIsRepostHeadView:feedItem andYPoint:0];
            ///content
            newYPointRepost = [self getHeightByContentIsRepostContent:feedItem andYPoint:newYPointRepost];
            ///语音信息
            newYPointRepost = [self getYPointByContentIsVoice:feedItem andYPoint:newYPointRepost isRepost:YES];
            ///地址信息
            newYPointRepost = [self getYPointByContentIsLocation:feedItem andYPoint:newYPointRepost isRepost:YES];
            ///图片
            newYPointRepost = [self getYPointByContentIsImg:feedItem andYPoint:newYPointRepost isRepost:YES];
            
            
            if (cellStatus == WorkGroupTypeStatusDetails) {
                ///转发内容右下角赞与评论按钮
                self.btnRepostPriase.hidden = NO;
                self.btnRepostReview.hidden = NO;
                ///评论数量
                NSString *comments = @"";
                if ([feedItem objectForKey:@"commentCount"]) {
                    comments = [NSString stringWithFormat:@"% li",[[feedItem safeObjectForKey:@"commentCount"] integerValue]];
                }
                
                [self.btnRepostReview setTitle:comments forState:UIControlStateNormal];
                
                
                comments = [comments stringByReplacingOccurrencesOfString:@" " withString:@""];
                CGFloat width = (comments.length-1)*5 +30;
                self.btnRepostReview.frame = CGRectMake(kScreen_Width-30-width, newYPointRepost, width, 15);
                
                
                ///赞
                NSString *feedUpCount = @"";
                if ([item objectForKey:@"feedUpCount"]) {
                    feedUpCount = [NSString stringWithFormat:@" %li",[[item safeObjectForKey:@"feedUpCount"] integerValue]];
                }
                [self.btnRepostPriase setTitle:feedUpCount forState:UIControlStateNormal];
                
                feedUpCount = [comments stringByReplacingOccurrencesOfString:@" " withString:@""];
                CGFloat widthFeedUpCount = (feedUpCount.length-1)*5 +30;
                self.btnRepostPriase.frame = CGRectMake(self.btnRepostReview.frame.origin.x-5-widthFeedUpCount, newYPointRepost, widthFeedUpCount, 15);
                
                newYPointRepost += 15;
            }else{
                
            }
            
            
        }else{
            ///没有转发内容
            self.viewRepost.hidden = NO;
            self.labelRepostName.hidden = YES;
            self.viewRepostAction.hidden = YES;
            
            self.lableRepostContent.frame = CGRectMake(5, 10, 200, 20);
            self.lableRepostContent.text = @"该动态已被删除";
            
            newYPointRepost += (30);
        }
        
        self.viewRepost.frame = CGRectMake(0, yPoint, kScreen_Width-20, newYPointRepost);
        self.viewRepostBg.frame = CGRectMake(10, 0, kScreen_Width-20, newYPointRepost);
        
        self.imgRepostArrow.frame = CGRectMake(20, 0, 13, 6);
        self.imgRepostBg.frame = CGRectMake(0, 5, kScreen_Width-20, newYPointRepost);
        
        
        ///背景框  UIIamgeView
        
        self.imgRepostBg.image = [CommonFuntion createImageWithColor:[UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:247.0f/255 alpha:1.0f]];
        self.imgRepostBg.layer.borderColor = [UIColor colorWithRed:220.0f/255 green:220.0f/255 blue:220.0f/255 alpha:1.0f].CGColor;
        self.imgRepostBg.layer.borderWidth = 0.5;
        
        
        if (newYPointRepost > 0) {
            newYPoint += (newYPointRepost+10);
        }
    }
    
    
    return newYPoint;
}

#pragma mark 转发内容头部

-(CGFloat)getHeightByContentIsRepostHeadView:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    
    ///user
    NSDictionary *user = nil;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"user"]]) {
        user = [item objectForKey:@"user"];
    }
    
    NSString *name = @"";
    if (user) {
        ///姓名
        if ([user objectForKey:@"name"]) {
            name = [user safeObjectForKey:@"name"];
        }
    }
    
    CGSize sizeName = [CommonFuntion getSizeOfContents:name Font:FONT_WORKGROUP_NAME withWidth:kScreen_Width-100 withHeight:20];
    self.labelRepostName.frame = CGRectMake(5, 7, sizeName.width, 20);
    self.labelRepostName.text = name;
    
    
    
    ///from
    NSDictionary *from = nil;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"from"]]) {
        from = [item objectForKey:@"from"];
    }
    
    
    ///所属行为
    self.viewRepostAction.hidden = YES;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"from"]] && [[item objectForKey:@"from"] objectForKey:@"name"]) {
        self.viewRepostAction.hidden = NO;
        NSString *name = [[item objectForKey:@"from"] safeObjectForKey:@"name"];
        CGSize sizeAction = [CommonFuntion getSizeOfContents:name Font:FONT_WORKGROUP_NAME withWidth:kScreen_Width-100 withHeight:20];
        self.viewRepostAction.frame = CGRectMake(self.labelRepostName.frame.origin.x+sizeName.width+5, self.labelRepostName.frame.origin.y, sizeAction.width+15, 21);
        
        self.labelRepostActionName.text = name;
    }
    
    newYPoint += (20+10);
    
    return newYPoint;
}



#pragma mark  转发content
-(CGFloat)getHeightByContentIsRepostContent:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    ///content
    NSString *content = @"";
    if ([item objectForKey:@"content"]) {
        content = [item safeObjectForKey:@"content"];
    }
    
    ///转发content文本内容 只显示两行
    self.lableRepostContent.hidden = YES;
    if (![content isEqualToString:@""]) {
        self.lableRepostContent.hidden = NO;
        CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_WORKGROUP_CONTENT withWidth:kScreen_Width-20-10 withHeight:60];
        
        self.lableRepostContent.frame = CGRectMake(5, yPoint, sizeContent.width, sizeContent.height);
        self.lableRepostContent.text = content;
        
        newYPoint += (sizeContent.height+10);
    }
    //    NSLog(@"content:%@",content);
    return newYPoint;
}


#pragma mark - @提到我的评论消息
-(CGFloat)getHeightByMsgViewContent:(NSDictionary *)item andYPoint:(CGFloat)yPoint{
    CGFloat newYPoint = yPoint;
    
    /// @提到我的评论消息
    self.viewCommentSource.hidden = YES;
    self.viewCommentSource.frame = CGRectMake(10, yPoint, 0, 0);
    self.viewCommentSource.backgroundColor = [UIColor colorWithRed:245.0f/255 green:245.0f/255 blue:247.0f/255 alpha:1.0f];
    self.viewCommentSource.layer.borderWidth = 0.5;
    self.viewCommentSource.layer.borderColor =  [UIColor colorWithRed:220.0f/255 green:220.0f/255 blue:220.0f/255 alpha:1.0f].CGColor;
    [self addSubview:self.viewCommentSource];

    ///source
    NSDictionary *source = nil;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"commentFrom"]]) {
        source = [item objectForKey:@"commentFrom"];
    }
    
    ///
    NSString *name = @"";
    NSString *image = @"";
    NSString *content = @"";
    if (source) {
        self.viewCommentSource.hidden = NO;
        self.viewCommentSource.frame = CGRectMake(10, yPoint, kScreen_Width-20, 50);
        
        NSDictionary *user = nil;
        if ([CommonFuntion checkNullForValue:[source objectForKey:@"user"]]) {
            user = [source objectForKey:@"user"];
        }
        
        ///姓名
        if ([user objectForKey:@"name"]) {
            name = [user safeObjectForKey:@"name"];
        }
        ///头像
        if ([user objectForKey:@"icon"]) {
            image = [user safeObjectForKey:@"icon"];
        }
        
        ///内容
        if ([source objectForKey:@"content"]) {
            content = [source safeObjectForKey:@"content"];
        }
        ///只显示一行
        self.labelContentSource.frame = CGRectMake(5, 27, kScreen_Width-70, 20);
        
        newYPoint +=(50);
    }
    self.imgIconSource.hidden = YES;
    [self.imgIconSource sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:[UIImage imageNamed:PLACEHOLDER_CONTACT_ICON]];
    self.labelNameSource.text = name;
    self.labelContentSource.text = content;
    
    return newYPoint;
}


#pragma mark - 获取当前cell height
+(CGFloat)getCellContentHeight:(NSDictionary *)item byCellStatus:(WorkGroupTypeStatus)cellStatus{
    
    if (!item) {
        return 0;
    }
    
    CGFloat height = 58;
    
    ///如果存在blog  则不显示content
    ///blog
    NSDictionary *blog = item;
    NSInteger type = 0;
    if ([item objectForKey:@"type"]) {
        type = [[item safeObjectForKey:@"type"] integerValue];
    }
    if (type != 1 && type !=2 && type != 3) {
        type = 0;
    }
    ///是博文
    if (type == 3) {
        float blogHeight = 0;
        
        ///详情页面
        if (cellStatus == WorkGroupTypeStatusDetails) {
            NSString *blogtitle = @"";
            ///标题
            if ([blog objectForKey:@"blogTitle"]) {
                blogtitle = [blog safeObjectForKey:@"blogTitle"];
            }
            
            CGSize sizeBlogTtile = [CommonFuntion getSizeOfContents:blogtitle Font:FONT_WORKGROUP_BLOG_TITLE withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
            
            
            if (![blogtitle isEqualToString:@""]) {
                blogHeight += (sizeBlogTtile.height+10);
            }
            
            
            NSString *blogcontent = @"";
            ///内容
            if ([blog objectForKey:@"content"]) {
                blogcontent = [blog safeObjectForKey:@"content"];
            }
            
            CGSize sizeBlogContent;
            
            if (![blogcontent isEqualToString:@""]) {
                
                //                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[blogcontent dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                //
                //                NSMutableAttributedString *attS = [[NSMutableAttributedString alloc] initWithAttributedString:attrStr];
                //
                //                 sizeBlogContent =  [attS boundingRectWithSize:CGSizeMake(kScreen_Width-20, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
                
                
                sizeBlogContent = [CommonFuntion getSizeOfContents:blogcontent Font:FONT_WORKGROUP_BLOG_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
                //            heightBlog1 =   [self heightForAttributedStringStatic:blogcontent Font:FONT_WORKGROUP_BLOG_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
                //            NSLog(@"heightBlog1:%f",heightBlog1);
                
                
                //            NSLog(@"sizeBlogContent.height:%f",sizeBlogContent.height);
                
                ///已经处于展开状态
                if ([item objectForKey:@"isExp"] && [[item objectForKey:@"isExp"] isEqualToString:@"yes"]) {
                    height += (20+10);
                }else{
                    if (sizeBlogContent.height > 130) {
                        sizeBlogContent.height = 130;
                        height += (20+10);
                    }else{
                        
                    }
                }
            }
            height += (blogHeight+sizeBlogContent.height+10);
        }else{
            height += 40;
        }
        
    }else{
        CGFloat praiseWidth = 0;
        ///praise 图标
        NSString *praiseIconName = @"";
        if ([item objectForKey:@"praise"]) {
            praiseIconName = [[self new] getIconByLogoValue:[[[item objectForKey:@"praise"] safeObjectForKey:@"logo"] integerValue]];
        }
        
        if (![praiseIconName isEqualToString:@""]) {
            praiseWidth = 30;
        }
        
        NSString *content = [item safeObjectForKey:@"content"];

//        NSString *content = @"";
//        if ([item objectForKey:@"content"]) {
//            content = [NSString stringWithFormat:@"%@    ",[item safeObjectForKey:@"content"]];
//        }
//        
//        
//        NSArray *userAt = nil;
//        if ([item objectForKey:@"alts"]) {
//            userAt = [item objectForKey:@"alts"];
//        }
//        
//        ///重组字符串
//        content = [CommonFuntion searchAtCharAndSetItValid:content atArray:userAt isAddressBookArray:FALSE];
        
        
        ///content
        if (![content isEqualToString:@""]) {
            CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_WORKGROUP_CONTENT withWidth:kScreen_Width-20-praiseWidth withHeight:MAX_WIDTH_OR_HEIGHT];
            
            ///已经处于展开状态
            if ([item objectForKey:@"isExp"] && [[item objectForKey:@"isExp"] isEqualToString:@"yes"]) {
                height += (20+10);
            }else{
                
                if (sizeContent.height > 130) {
                    sizeContent.height = 130;
                    height += (20+10);
                }else{
                    
                }
            }
            
            height += (sizeContent.height+10);
        }
    }
    
    
    
    ///任务部分
    if ([item objectForKey:@"recordNew"] &&  [[item objectForKey:@"recordNew"] objectForKey:@"taskId"]) {
        NSInteger taskHeight = 0;
        NSDictionary *itemTask = [item objectForKey:@"recordNew"];
        ///任务描述
        NSString *taskDescription = @"";
        if ([itemTask objectForKey:@"taskDescription"]) {
            taskDescription = [itemTask safeObjectForKey:@"taskDescription"];
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
            CGSize sizeTaskContent = [CommonFuntion getSizeOfContents:taskContent Font:FONT_DETAILS_CONTENT withWidth:kScreen_Width-20 withHeight:MAX_WIDTH_OR_HEIGHT];
            taskHeight += (sizeTaskContent.height+10);
        }
        
        taskHeight += (20+10);
        
        height += taskHeight;
    }
    
    ///task view
    
    ///该任务由谁创建完成之类
    //    if ([item objectForKey:@"recordNew"]  && [[item objectForKey:@"recordNew"] objectForKey:@"taskCreatedBy"]) {
    //        height += (20+10);
    //    }
    
    ///voice
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"audio"]]) {
        NSString *soundUrl = @"";
        if ([[item objectForKey:@"audio"] objectForKey:@"url"]) {
            soundUrl = [[item objectForKey:@"audio"] safeObjectForKey:@"url"];
        }
        
        if (soundUrl && soundUrl.length > 0) {
             height += (40+10);
        }
    }
    
    ///文件
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"file"]] && [item objectForKey:@"fileType"]) {
        if ([[item safeObjectForKey:@"fileType"]  integerValue] == 2) {
            ///文件
            height += (40+10);
        }
    }
    
    
    ///position
    NSString *position = @"";
    if ([item objectForKey:@"position"]) {
        position = [item safeObjectForKey:@"position"];
    }
    
    double  latitude = 0;
    double  longitude = 0;
    if ([item objectForKey:@"latitude"]) {
        latitude = [[item safeObjectForKey:@"latitude"] doubleValue];
    }
    if ([item objectForKey:@"longitude"]) {
        longitude = [[item safeObjectForKey:@"longitude"] doubleValue];
    }
    
    
    if (![position isEqualToString:@""] && latitude !=0 && longitude !=0) {
        if ([[self new] isContainPic:item]) {
            height += (20+10);
        }else{
            height += (85+10);
        }
    }
    
#warning 判断是转发还是正常
    /// fileType  0 不存在  1图片  2附件
    /// imageFiles 判断图片
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"imageFiles"]] && [item objectForKey:@"fileType"]) {
        if ([[item safeObjectForKey:@"fileType"]  integerValue] == 1) {
            NSArray *arrayImg = [item objectForKey:@"imageFiles"];
            
            NSInteger count = [arrayImg count];
            
            if (count > 0) {
                CGFloat imgHeight = [[self new] getImgViewHeight:count];
                height += (imgHeight+10);
            }
        }
    }
    
    ///转发
    if ([self getRepostViewHeight:item byCellStatus:cellStatus] > 0) {
        height += ([self getRepostViewHeight:item byCellStatus:cellStatus]+10);
    }
    
    
    NSDictionary *source = nil;
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"commentFrom"]])  {
        source = [item objectForKey:@"commentFrom"];
    }
    
    if (source) {
        ///作为列表cell展示时  非详情页面
        if (cellStatus == WorkGroupTypeStatusCell) {
             height += (50);
        }
    }
    
    ///做为详情显示时
    ///底部view
    if (cellStatus == WorkGroupTypeStatusDetails) {
        ///底部view
        height += (20+5);
    }else{
        if (source) {
            height += (10);
        }else{
            height += (40+10);
        }
    }
    
    return height;
}

///获取转发view的height
+(CGFloat)getRepostViewHeight:(NSDictionary *)item byCellStatus:(WorkGroupTypeStatus)cellStatus{
    
    if (!item) {
        return 0;
    }
    CGFloat height = 0;
    
    ///是转发信息
    if ([[item objectForKey:@"type"] integerValue] == 2) {
        NSDictionary *feedItem = nil;
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            feedItem = [item objectForKey:@"forward"];
        }
        
        ///有转发内容
        if (feedItem) {
            ///头部
            height += 30;
            
            ///content
            NSString *content = @"";
            if ([feedItem objectForKey:@"content"]) {
                content = [feedItem safeObjectForKey:@"content"];
            }
            
            if (![content isEqualToString:@""]) {
                
                CGSize sizeContent = [CommonFuntion getSizeOfContents:content Font:FONT_WORKGROUP_CONTENT withWidth:kScreen_Width-20 withHeight:60];
                
                height += (sizeContent.height+10);
            }
            
            ///voice
            if ([CommonFuntion checkNullForValue:[item objectForKey:@"audio"]]) {
                height += (40+10);
            }
            
            ///position
            NSString *position = @"";
            if ([feedItem objectForKey:@"position"]) {
                position = [feedItem safeObjectForKey:@"position"];
            }
            
            double  latitude = 0;
            double  longitude = 0;
            if ([feedItem objectForKey:@"latitude"]) {
                latitude = [[feedItem safeObjectForKey:@"latitude"] doubleValue];
            }
            if ([feedItem objectForKey:@"longitude"]) {
                longitude = [[feedItem safeObjectForKey:@"longitude"] doubleValue];
            }
            
            
            if (![position isEqualToString:@""] && latitude != 0 && longitude != 0) {
                
                BOOL isContain = FALSE;
                
                //    self.viewImage.hidden = YES;
                /// fileType  0 不存在  1图片  2附件
                /// imageFiles 判断图片
                if ([CommonFuntion checkNullForValue:[feedItem objectForKey:@"imageFiles"]] && [feedItem objectForKey:@"fileType"]) {
                    if ([[feedItem safeObjectForKey:@"fileType"]  integerValue] == 1) {
                        if ([[feedItem objectForKey:@"imageFiles"] count] > 0) {
                            isContain = TRUE;
                        }
                    }
                }
                
                ///如果包含图片则地址信息只显示首行
                if (isContain) {
                    height += (20+10);
                }else{
                    height += (85+10);
                }
            }
            
            
            //    self.viewImage.hidden = YES;
            /// fileType  0 不存在  1图片  2附件
            /// imageFiles 判断图片
            if ([CommonFuntion checkNullForValue:[feedItem objectForKey:@"imageFiles"]] && [feedItem objectForKey:@"fileType"]) {
                if ([[feedItem safeObjectForKey:@"fileType"]  integerValue] == 1) {
                    NSArray *arrayImg = [feedItem objectForKey:@"imageFiles"];
                    NSInteger count = [arrayImg count];
                    if (count > 0) {
                        CGFloat imgHeight = [[self new] getImgViewHeight:count];
                        height += (imgHeight+0);
                    }
                }
            }
            
            
            if (cellStatus == WorkGroupTypeStatusDetails) {
                height += 15;
            }
        }else{
            ///动态已经被删除
            height += 30;
        }
    }
    
    return height;
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
    //    NSLog(@"setImgShow count:%li",count);
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
    
    ///转发内容
    if ([[item objectForKey:@"type"] integerValue] == 2) {
        if ([CommonFuntion checkNullForValue:[item objectForKey:@"forward"]]) {
            item = [item objectForKey:@"forward"];
        }
    }
    
    /// fileType  0 不存在  1图片  2附件
    /// imageFiles 判断图片
    if ([CommonFuntion checkNullForValue:[item objectForKey:@"imageFiles"]] && [item objectForKey:@"fileType"]) {
        if ([[item safeObjectForKey:@"fileType"]  integerValue] == 1) {
            /*
            NSArray *arrayImg = [item objectForKey:@"imageFiles"];
            
            if (arrayImg && [arrayImg count] > 0) {
                NSInteger count = [arrayImg count];
                UITapGestureRecognizer *gesture;
                NSInteger imgIndex = 0;
                
                NSMutableArray *tempImagesArray = [NSMutableArray arrayWithCapacity:0];
                
                ///小图
#warning 该替换为lurl  图片太大
                NSString *imgSizeType = @"minUrl";
                if (count > 0) {
                    [self.img1 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:0] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    self.img1.tag = kTag_imageView;
                    [self.img1 addGestureRecognizer:gesture];
                    
                    self.img1.frame = CGRectMake(2, 0, 70, 70);
                    PhotoItem *photoItem = [[PhotoItem alloc] init];
                    photoItem.url = arrayImg[0][@"url"];
                    photoItem.minUrl = arrayImg[0][@"minUrl"];
                    photoItem.srcImageView = self.img1;
                    [tempImagesArray addObject:photoItem];
                    
                    imgIndex++;
                }
                
                if (count > 1) {
                    [self.img2 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:1] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    self.img2.tag = kTag_imageView + 1;
                    [self.img2 addGestureRecognizer:gesture];
                    
                    self.img2.frame = CGRectMake(77, 0, 70, 70);
                    PhotoItem *photoItem = [[PhotoItem alloc] init];
                    photoItem.url = arrayImg[1][@"url"];
                    photoItem.minUrl = arrayImg[1][@"minUrl"];
                    photoItem.srcImageView = self.img2;
                    [tempImagesArray addObject:photoItem];
                    
                    imgIndex++;
                }
                
                if (count > 2) {
                    [self.img3 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:2] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    self.img3.tag = kTag_imageView + 2;
                    [self.img3 addGestureRecognizer:gesture];
                    
                    self.img3.frame = CGRectMake(152, 0, 70, 70);
                    PhotoItem *photoItem = [[PhotoItem alloc] init];
                    photoItem.url = arrayImg[2][@"url"];
                    photoItem.minUrl = arrayImg[2][@"minUrl"];
                    photoItem.srcImageView = self.img3;
                    [tempImagesArray addObject:photoItem];
                    imgIndex++;
                }
                
                if (count > 3) {
                    [self.img4 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:3] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    self.img4.tag = kTag_imageView + 3;
                    [self.img4 addGestureRecognizer:gesture];
                    
                    self.img4.frame = CGRectMake(2, 75, 70, 70);
                    PhotoItem *photoItem = [[PhotoItem alloc] init];
                    photoItem.url = arrayImg[3][@"url"];
                    photoItem.minUrl = arrayImg[3][@"minUrl"];
                    photoItem.srcImageView = self.img4;
                    [tempImagesArray addObject:photoItem];
                    imgIndex++;
                }
                
                if (count > 4) {
                    [self.img5 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:4] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    self.img5.tag = kTag_imageView + 4;
                    [self.img5 addGestureRecognizer:gesture];
                    
                    self.img5.frame = CGRectMake(77, 75, 70, 70);
                    PhotoItem *photoItem = [[PhotoItem alloc] init];
                    photoItem.url = arrayImg[4][@"url"];
                    photoItem.minUrl = arrayImg[4][@"minUrl"];
                    photoItem.srcImageView = self.img5;
                    [tempImagesArray addObject:photoItem];
                    imgIndex++;
                }
                
                if (count > 5) {
                    [self.img6 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:5] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    self.img6.tag = kTag_imageView + 5;
                    [self.img6 addGestureRecognizer:gesture];
                    
                    self.img6.frame = CGRectMake(152, 75, 70, 70);
                    PhotoItem *photoItem = [[PhotoItem alloc] init];
                    photoItem.url = arrayImg[5][@"url"];
                    photoItem.minUrl = arrayImg[5][@"minUrl"];
                    photoItem.srcImageView = self.img6;
                    [tempImagesArray addObject:photoItem];
                    imgIndex++;
                }
                
                if (count > 6) {
                    [self.img7 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:6] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    self.img7.tag = kTag_imageView + 6;
                    [self.img7 addGestureRecognizer:gesture];
                    
                    self.img7.frame = CGRectMake(2, 150, 70, 70);
                    PhotoItem *photoItem = [[PhotoItem alloc] init];
                    photoItem.url = arrayImg[6][@"url"];
                    photoItem.minUrl = arrayImg[6][@"minUrl"];
                    photoItem.srcImageView = self.img7;
                    [tempImagesArray addObject:photoItem];
                    
                    imgIndex++;
                }
                
                if (count > 7) {
                    [self.img8 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:7] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    self.img8.tag = kTag_imageView + 7;
                    [self.img8 addGestureRecognizer:gesture];
                    
                    self.img8.frame = CGRectMake(77, 150, 70, 70);
                    PhotoItem *photoItem = [[PhotoItem alloc] init];
                    photoItem.url = arrayImg[7][@"url"];
                    photoItem.minUrl = arrayImg[7][@"minUrl"];
                    photoItem.srcImageView = self.img8;
                    [tempImagesArray addObject:photoItem];
                    
                    imgIndex++;
                }
                
                if (count > 8) {
                    [self.img9 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:8] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    self.img9.tag = kTag_imageView + 8;
                    [self.img9 addGestureRecognizer:gesture];
                    
                    self.img9.frame = CGRectMake(152, 150, 70, 70);
                    PhotoItem *photoItem = [[PhotoItem alloc] init];
                    photoItem.url = arrayImg[8][@"url"];
                    photoItem.minUrl = arrayImg[8][@"minUrl"];
                    photoItem.srcImageView = self.img9;
                    [tempImagesArray addObject:photoItem];
                    
                    imgIndex++;
                }
                
                self.imagesArray = tempImagesArray;
             
            }
             */
            
            
            NSArray *arrayImg = [item objectForKey:@"imageFiles"];
            
            if (arrayImg && [arrayImg count] > 0) {
                NSInteger count = [arrayImg count];
                UITapGestureRecognizer *gesture;
                NSString *tagOfImg ;
                NSInteger imgIndex = 0;
                ///小图
#warning 该替换为lurl  图片太大
                NSString *imgSizeType = @"minUrl";
                if (count > 0) {
                    //                    NSLog(@"arrayImg url:%@",[[arrayImg objectAtIndex:0] safeObjectForKey:@"pic"]);
                    [self.img1 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:0] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    tagOfImg = [NSString stringWithFormat:@"%li%li",index.section+1,imgIndex];
                    self.img1.tag = [tagOfImg integerValue];
                    [self.img1 addGestureRecognizer:gesture];
                    imgIndex++;
                }
                
                if (count > 1) {
                    [self.img2 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:1] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    tagOfImg = [NSString stringWithFormat:@"%li%li",index.section+1,imgIndex];
                    self.img2.tag = [tagOfImg integerValue];
                    [self.img2 addGestureRecognizer:gesture];
                    imgIndex++;
                }
                
                if (count > 2) {
                    [self.img3 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:2] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    tagOfImg = [NSString stringWithFormat:@"%li%li",index.section+1,imgIndex];
                    self.img3.tag = [tagOfImg integerValue];
                    [self.img3 addGestureRecognizer:gesture];
                    imgIndex++;
                }
                
                if (count > 3) {
                    [self.img4 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:3] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    tagOfImg = [NSString stringWithFormat:@"%li%li",index.section+1,imgIndex];
                    self.img4.tag = [tagOfImg integerValue];
                    [self.img4 addGestureRecognizer:gesture];
                    imgIndex++;
                }
                
                if (count > 4) {
                    [self.img5 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:4] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    tagOfImg = [NSString stringWithFormat:@"%li%li",index.section+1,imgIndex];
                    self.img5.tag = [tagOfImg integerValue];
                    [self.img5 addGestureRecognizer:gesture];
                    imgIndex++;
                }
                
                if (count > 5) {
                    [self.img6 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:5] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    tagOfImg = [NSString stringWithFormat:@"%li%li",index.section+1,imgIndex];
                    self.img6.tag = [tagOfImg integerValue];
                    [self.img6 addGestureRecognizer:gesture];
                    imgIndex++;
                }
                
                if (count > 6) {
                    [self.img7 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:6] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    tagOfImg = [NSString stringWithFormat:@"%li%li",index.section+1,imgIndex];
                    self.img7.tag = [tagOfImg integerValue];
                    [self.img7 addGestureRecognizer:gesture];
                    imgIndex++;
                }
                
                if (count > 7) {
                    [self.img8 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:7] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    tagOfImg = [NSString stringWithFormat:@"%li%li",index.section+1,imgIndex];
                    self.img8.tag = [tagOfImg integerValue];
                    [self.img8 addGestureRecognizer:gesture];
                    imgIndex++;
                }
                
                if (count > 8) {
                    [self.img9 sd_setImageWithURL:[NSURL URLWithString:[[arrayImg objectAtIndex:8] objectForKey:imgSizeType]] placeholderImage:[UIImage imageNamed:PLACEHOLDER_REVIEW_IMG]];
                    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfImgView:)];
                    tagOfImg = [NSString stringWithFormat:@"%li%li",index.section+1,imgIndex];
                    self.img9.tag = [tagOfImg integerValue];
                    [self.img9 addGestureRecognizer:gesture];
                    imgIndex++;
                }
            }
            
        }
    }
    
}
///imageview添加点击手势
-(void)tapHandleOfImgView:(UITapGestureRecognizer *)tap{
    
    UIImageView *tapImg = (UIImageView *)tap.view;
    NSString *tagIndex = [NSString stringWithFormat:@"%li",tapImg.tag];
    ///section 对应当前cell在列表中的行下标
    NSInteger section = [[tagIndex substringToIndex:tagIndex.length-1] integerValue]-1 ;
    ///对应当前图片在cell中的下标
    NSInteger row = [[tagIndex substringFromIndex:tagIndex.length-1] integerValue] ;
    
    NSIndexPath *imgIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    //    NSLog(@"tapHandleOfImgView section%li  row:%li",section,row);
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickImageViewEvent:)]) {
        [self.delegate clickImageViewEvent:imgIndexPath];
    }
    
    
//    if ((tapImg.tag - kTag_imageView) < self.imagesArray.count) {
//        PhotoItem *selectedItem = self.imagesArray[tapImg.tag - kTag_imageView];
//        [PhotoBrowser sharedInstance].backgroundScale = 1.0;
//        [[PhotoBrowser sharedInstance] showWithItems:self.imagesArray selectedItem:selectedItem];
//    }
}



#pragma mark - cell中相关事件
///cell里控件添加事件
-(void)addClickEventForCellView:(NSDictionary *)item withIndex:(NSIndexPath *)index{
    
    ///点击头像事件
    [self.btnIcon addTarget:self action:@selector(gotoPersonalInformation:) forControlEvents:UIControlEventTouchUpInside];
    self.btnIcon.tag = index.section;
    
    
    ///点击右上角菜单事件
    [self.btnMenu addTarget:self action:@selector(showMenuView:) forControlEvents:UIControlEventTouchUpInside];
    self.btnMenu.tag = index.section;
    
    
    ///点击来自XXX事件
    [self.btnFrom addTarget:self action:@selector(gotoFromView:) forControlEvents:UIControlEventTouchUpInside];
    self.btnFrom.tag = index.section;
    
    ///展开按钮
    [self.btnExpContent addTarget:self action:@selector(expContentView:) forControlEvents:UIControlEventTouchUpInside];
    self.btnExpContent.tag = index.section;
    
    [self.btnBlogExp addTarget:self action:@selector(expContentView:) forControlEvents:UIControlEventTouchUpInside];
    self.btnBlogExp.tag = index.section;
    
    ///点击底部菜单 评论、赞事件
    [self.btnRepost addTarget:self action:@selector(repostMessage:) forControlEvents:UIControlEventTouchUpInside];
    self.btnRepost.tag = index.section;
    
    ///评论
    [self.btnReview addTarget:self action:@selector(reviewMessage:) forControlEvents:UIControlEventTouchUpInside];
    self.btnReview.tag = index.section;
    
    
    ///是否已经赞
    NSInteger isFeedUp = [[item safeObjectForKey:@"isFeedUp"] integerValue];
//    if ([item objectForKey:@"isFeedUp"]) {
//        isFeedUp = [[item safeObjectForKey:@"isFeedUp"] integerValue];
//    }
    ///还没有赞
    if (isFeedUp == 1) {
        ///赞
        [self.btnPraise addTarget:self action:@selector(praiseMessage:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        ///去除点击事件
        [self.btnPraise removeTarget:self action:@selector(praiseMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnPraise addTarget:self action:@selector(praisedMessage:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.btnPraise.tag = index.section;
    
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
    
//    __block WorkGroupRecordCellB *mySelf = self;
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
    
    ///转发view点击事件
    UITapGestureRecognizer *gesture;
    gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfRepostView:)];
    self.viewRepost.tag = index.section;
    [self.viewRepost addGestureRecognizer:gesture];
    
    
    ///点击地址事件
    [self.btnAddress addTarget:self action:@selector(gotoMapView:) forControlEvents:UIControlEventTouchUpInside];
    self.btnAddress.tag = index.section;
    
    ///地址view点击事件
    UITapGestureRecognizer *gestureLocation;
    gestureLocation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfgestureLocationView:)];
    self.viewAddressContent.tag = index.section;
    [self.viewAddressContent addGestureRecognizer:gestureLocation];
    
    
    ///文件view点击事件
    UITapGestureRecognizer *gestureFile;
    gestureFile = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandleOfgesturegestureFile:)];
    self.viewFile.tag = index.section;
    [self.viewFile addGestureRecognizer:gestureFile];
    //语音btnbtnVoice点击事件
    self.btnVoice.tag = index.section;
    
}


////点击头像事件
-(void)gotoPersonalInformation:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickUserIconEvent:)]) {
        [self.delegate clickUserIconEvent:btn.tag];
    }
}

///点击右上角菜单事件
-(void)showMenuView:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickRightMenuEvent:)]) {
        [self.delegate clickRightMenuEvent:btn.tag];
    }
}

///点击来自XXX事件
-(void)gotoFromView:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickFromEvent:)]) {
        [self.delegate clickFromEvent:btn.tag];
    }
}

///展开全部
-(void)expContentView:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickExpContentEvent:)]) {
        [self.delegate clickExpContentEvent:btn.tag];
    }
}

///转发
-(void)repostMessage:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickRepostEvent:)]) {
        [self.delegate clickRepostEvent:btn.tag];
    }
}

///评论
-(void)reviewMessage:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickReviewEvent:)]) {
        [self.delegate clickReviewEvent:btn.tag];
    }
}

///赞
-(void)praiseMessage:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    [btn setImage:[UIImage imageNamed:@"feed_praise_select.png"] forState:UIControlStateNormal];
    
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.values = @[@(0.1),@(1.0),@(1.5)];
    k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
    k.calculationMode = kCAAnimationLinear;
    [btn.layer addAnimation:k forKey:@"SHOW"];
    
    
    dispatch_queue_t queue= dispatch_get_main_queue();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), queue, ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(clickPraiseEvent:)]) {
            [self.delegate clickPraiseEvent:btn.tag];
        }
    });
    
    
    
    /*
     [UIView animateWithDuration:2 animations:^{
     
     } completion:^(BOOL finished) {
     
     }];
     */
}

///已赞过
-(void)praisedMessage:(id)sender{
    kShowHUD2(@"该动态您已赞过");
}

-(void)updateFeedCount:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickPraiseEvent:)]) {
        [self.delegate clickPraiseEvent:section];
    }
}


///点击转发view区域
-(void)tapHandleOfRepostView:(UITapGestureRecognizer *)tap{
    UIView *tapView = (UIView *)tap.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickRepostViewEvent:)]) {
        [self.delegate clickRepostViewEvent:tapView.tag];
    }
}


///点击地址事件
-(void)gotoMapView:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickAddressEvent:)]) {
        [self.delegate clickAddressEvent:btn.tag];
    }
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


#pragma mark - 根据logo值 获取对应的图标
-(NSString *)getIconByLogoValue:(NSInteger)logo{
    return @"feed_happiness.png";
    //    return @"praise_icon.png";
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

- (IBAction)playVoiceFile:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickVoiceDataEvent:)]) {
        [self.delegate clickVoiceDataEvent:sender.tag];
    }
}

#pragma mark - key:value

/*
 
 type 3 系统生成  1 发布  2 转发
 fileType  0没有  1 图片  2附件
 
 
 */


- (float)Calculating_Text_Height_3_Width:(CGFloat)width WithString:(NSAttributedString *)string {
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] init];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, FLT_MAX)];
    [textContainer setLineFragmentPadding:0.0];
    [layoutManager addTextContainer:textContainer];
    [textStorage setAttributedString:string];
    [layoutManager glyphRangeForTextContainer:textContainer];
    CGRect frame = [layoutManager usedRectForTextContainer:textContainer];
    NSLog(@"3:%@", NSStringFromCGRect(frame));
    
    
    return frame.size.height;
    /*
     https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/StringHeight.html
     http://www.cocoachina.com/b/?p=160
     */
    
}


- (float) heightForAttributedString:(NSString *)attrStr Font:(UIFont*)font withWidth:(CGFloat)width withHeight:(CGFloat)height{
    // 计算文本的大小
    //    CGSize sizeToFit = [attrStr boundingRectWithSize:CGSizeMake(width, height) // 用于计算文本绘制时占据的矩形块
    //                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
    //                                        attributes:dic        // 文字的属性
    //                                           context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil
    //    NSAttributedString *string = [[NSAttributedString alloc] initWithData:[attrStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:attrStr];
    
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    CGSize sizeToFit = rect.size;
    return sizeToFit.height;
}




+ (float) heightForAttributedStringStatic:(NSString *)attrStr Font:(UIFont*)font withWidth:(CGFloat)width withHeight:(CGFloat)height{
    // 计算文本的大小
    //    CGSize sizeToFit = [attrStr boundingRectWithSize:CGSizeMake(width, height) // 用于计算文本绘制时占据的矩形块
    //                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading // 文本绘制时的附加选项
    //                                        attributes:dic        // 文字的属性
    //                                           context:nil].size; // context上下文。包括一些信息，例如如何调整字间距以及缩放。该对象包含的信息将用于文本绘制。该参数可为nil
    NSAttributedString *string = [[NSAttributedString alloc] initWithData:[attrStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    CGSize sizeToFit = rect.size;
    return sizeToFit.height;
}


- (int)getAttributedStringHeightWithString:(NSString *) attrStr Font:(UIFont*)font withWidth:(CGFloat)width withHeight:(CGFloat)height{
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithData:[attrStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    int total_height = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, height);  //这里的高要设置足够大
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (__bridge CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    total_height = MAX_WIDTH_OR_HEIGHT - line_y + (int) descent +1;    //+1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    
    return total_height;
}

@end
