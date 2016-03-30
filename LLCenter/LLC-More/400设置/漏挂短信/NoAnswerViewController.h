//
//  NoAnswerViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"

@interface NoAnswerViewController : AppsBaseViewController


@property (strong, nonatomic) IBOutlet UIView *viewFooter;

///短信签名
@property (strong, nonatomic) IBOutlet UIButton *btnSelectSign;
@property (strong, nonatomic) IBOutlet UIImageView *imgIconSelectSign;

///发送时间
@property (strong, nonatomic) IBOutlet UIButton *btnStartTime;
@property (strong, nonatomic) IBOutlet UIButton *btnStopTime;
@property (strong, nonatomic) IBOutlet UIButton *btnWeekAll;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek1;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek2;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek3;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek4;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek5;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek6;
@property (strong, nonatomic) IBOutlet UIButton *btnWeek7;


@property (strong, nonatomic) IBOutlet UILabel *labelRepeat;

@property (strong, nonatomic) IBOutlet UIButton *btnRepeat;
@property (strong, nonatomic) IBOutlet UIImageView *imgIconRepeat;


///分割线
@property (strong, nonatomic) IBOutlet UIImageView *imgLine1;
@property (strong, nonatomic) IBOutlet UIImageView *imgLine2;
@property (strong, nonatomic) IBOutlet UIImageView *imgLine3;


///手机号码

@property (strong, nonatomic) IBOutlet UILabel *labelPhone;
@property (strong, nonatomic) IBOutlet UITextField *textfieldPhone;






///周一周日
- (IBAction)selectSendWeekTime:(id)sender;

///开始时间-结束时间
- (IBAction)selectTime:(id)sender;

///短信签名
- (IBAction)selectMsgSign:(id)sender;

///重复频率
- (IBAction)selectRepeat:(id)sender;



///短信签名head
@property (strong, nonatomic) IBOutlet UIView *viewHeadSign;

@property (strong, nonatomic) IBOutlet UIImageView *lineSignTop;

///短信签名说明
@property (strong, nonatomic) IBOutlet UILabel *lableSignIntroTag;

@property (strong, nonatomic) IBOutlet UILabel *lableSignIntro;


@property (strong, nonatomic) IBOutlet UIImageView *imgSignArrow;

@property (strong, nonatomic) IBOutlet UIImageView *imgStartArrow;

@property (strong, nonatomic) IBOutlet UIImageView *imgStopArrow;

@property (strong, nonatomic) IBOutlet UIImageView *imgRepeatArrow;





@end
