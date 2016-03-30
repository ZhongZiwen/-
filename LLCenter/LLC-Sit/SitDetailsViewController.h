//
//  SitDetailsViewController.h
//  坐席详情
//
//  Created by sungoin-zjp on 16/1/5.
//
//

#import <UIKit/UIKit.h>

@interface SitDetailsViewController : BaseViewController


@property (strong, nonatomic) IBOutlet UIView *headviewDetail;

@property (strong, nonatomic) IBOutlet UITextField *tfJieruNum;
@property (strong, nonatomic) IBOutlet UITextField *tfUserName;
@property (strong, nonatomic) IBOutlet UITextField *tfJobNumber;
@property (strong, nonatomic) IBOutlet UITextField *tfPhone;

//权限
@property (strong, nonatomic) IBOutlet UILabel *labelJieTing;
@property (strong, nonatomic) IBOutlet UIButton *btnJieTing;
@property (strong, nonatomic) IBOutlet UISwitch *switchJieTing;

@property (strong, nonatomic) IBOutlet UILabel *labelWaiHu;
@property (strong, nonatomic) IBOutlet UIButton *btnWaiHu;
@property (strong, nonatomic) IBOutlet UISwitch *switchWaiHu;

@property (strong, nonatomic) IBOutlet UIView *lineBottom;




@property (strong, nonatomic) IBOutlet UILabel *labelNavTag;

@property (strong, nonatomic) IBOutlet UIButton *btnNavBarName;
@property (strong, nonatomic) IBOutlet UIButton *btnArrow;

@property (strong, nonatomic) IBOutlet UIButton *btnDelete;
@property (strong, nonatomic) IBOutlet UITableView *tableviewNav;


///坐席信息
@property (nonatomic,strong) NSDictionary *sitDetail;
@property (nonatomic,strong) NSString *groupName;
@property (nonatomic,strong) NSString *groupId;


- (IBAction)switchbtnClickEvent:(id)sender;

- (IBAction)switchValueChange:(id)sender;


///刷新坐席列表
@property (nonatomic, copy) void (^NotifySitListBlock)(void);
///导航信息
@property(nonatomic,strong)NSDictionary *navigationDic;

@end
