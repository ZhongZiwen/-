//
//  ContactBookAddNewLevel1ViewController.h
//  lianluozhongxin  新建坐席
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsInfo.h"

@interface ContactBookAddNewLevel1ViewController : AppsBaseViewController {
    IBOutlet UITextField *tfUserName,*tfUserNumber,*tfPhone,*tfPassword,*tfJieruNum;
    IBOutlet UIView *groupSelection;
    IBOutlet UILabel *labelGroups;
    
    IBOutlet UIView *view_line1,*view_line2,*view_line3,*view_line4,*view_line5,*view_line6;
    
    IBOutlet UILabel *label_name_tag,*label_num_tag,*label_phone_tag,*label_password_tag,*label_jieting_tag,*label_waihu_tag,*label_jieting_show,*label_waihu_show;
    
    IBOutlet UISwitch *switchJieTing,*switchWaiHu;
    
    IBOutlet UIView *view_content_bg;
    IBOutlet UIButton *btnGroupClick,*btnExpand;
    
    IBOutlet UIButton *btnJieTingBg,*btnWaiHuBg;
}

@property (nonatomic,strong) ContactsInfo *detailContactInfo;

- (IBAction)btnAction:(id)sender;

-(IBAction)switchValueChange:(id)sender;

- (IBAction)switchBgClickEvent:(id)sender;

///刷新坐席列表
@property (nonatomic, copy) void (^NotifySitListBlock)(void);

///导航信息
@property(nonatomic,strong)NSDictionary *navigationDic;

@end
