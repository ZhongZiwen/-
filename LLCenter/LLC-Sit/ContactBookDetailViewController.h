//
//  ContactBookDetailViewController.h
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsInfo.h"

@interface ContactBookDetailViewController : AppsBaseViewController {
    IBOutlet UITextField *tfUserName,*tfJobNumber,*tfPhone;
    IBOutlet UILabel *labelGroupName;
    IBOutlet UIButton *btnExpand,*btnDelete;
    IBOutlet UITableView *tbView;
    IBOutlet UIScrollView *scView;
    
    
    // UI适配
    IBOutlet UIView *view_line1,*view_line2,*view_line3,*view_lin4,*view_lin5,*view_lin6;
    IBOutlet UILabel *label_name_tag,*label_num_tag,*label_phone_tag,*label_site_type_tag,*label_jieting_tag,*label_waihu_tag,*label_jieting_show,*label_waihu_show;
    
    IBOutlet UILabel *labelJieTing,*labelWaiHu;
    
    IBOutlet UILabel *labelQuanXian;
    
    IBOutlet UISwitch *switchJieTing,*switchWaiHu;
    
    IBOutlet UIButton *btnGroupClick;
    
    IBOutlet UIView *view_content_bg;
    
    IBOutlet UIButton *btnJieTingBg,*btnWaiHuBg;
    
    NSMutableArray *dataSource;
}

@property (nonatomic,strong) ContactsInfo *detailContactInfo;
@property (nonatomic,strong) NSString *groupName;
@property (nonatomic,strong) NSString *groupId;

- (IBAction)btnAction:(id)sender;

-(IBAction)switchValueChange:(id)sender;

- (IBAction)switchBgClickEvent:(id)sender;


///刷新座席列表
@property (nonatomic, copy) void (^NotifySitStatusListBlock)(void);

@end
