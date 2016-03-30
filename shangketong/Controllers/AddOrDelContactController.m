//
//  AddOrDelContactController.m
//  shangketong
//
//  Created by 蒋 on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "AddOrDelContactController.h"
#import "EditTextForDetailController.h"
#import "UITapImageView.h"
#import <UIImageView+WebCache.h>
#import <POPSpringAnimation.h>
#import "InfoViewController.h"
#import "CommonConstant.h"
#import "AddOrDeleteCell.h"
#import "EditTopicController.h"
#import "ContactModel.h"
#import "AFNHttp.h"
#import "ChatViewController.h"
#import "IM_FMDB_FILE.h"
#import "ReportToServiceViewController.h"
#import "StartChatViewController.h"

#import "AddOrDeleteCollectionCell.h"
#import "InfoCollectionCell.h"


#define kSpaceWidth 15
#define kImageViewWidth (kScreen_Width - 6 * kSpaceWidth)/5.0
#define angelToRandian(x)  ((x)/180.0*M_PI)

@interface AddOrDelContactController ()<UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) NSMutableArray *contactArray;
@property (nonatomic, strong) NSMutableArray *addContactArray;
@property (nonatomic, assign) BOOL isDelete;

@property (nonatomic, strong) UICollectionView *collcetionView;
@end

@implementation AddOrDelContactController

- (void)viewDidLoad {
    [super viewDidLoad];
    _contactArray = [NSMutableArray arrayWithArray:_contactModelArray];
    _addContactArray = [NSMutableArray arrayWithCapacity:0];
    
    UIView *V = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableViewAddOrDel setTableFooterView:V];
    
    self.tableViewAddOrDel.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"举报" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    _isDelete = NO;
    [self.view addSubview:self.collcetionView];
    
}
#pragma mark - 举报
- (void)backButtonPress {
    ReportToServiceViewController *controller = [[ReportToServiceViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
//    EditTextForDetailController *controller = [EditTextForDetailController new];
//    controller.backTextViewValveBlock = ^(NSString *string) {
//        NSLog(@"%@", string);
//    };
//    [self.navigationController pushViewController:controller animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showActionSheet {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除并退出", nil];
    [action showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"删除并退出");
        [self  deleteOneGroupWithType];
    }
}
- (void)pushViewController:(UITapGestureRecognizer *)tap {
    InfoCollectionCell *cell = (InfoCollectionCell *)tap.view;
    EditTopicController *controller = [[EditTopicController alloc] init];
    controller.topicTitle = cell.topicNameLabel.text;
    controller.BackGroupTopicBlock = ^(NSString *string) {
        cell.topicNameLabel.text = string;
        __weak typeof(self) weak_self = self;
        weak_self.title = string;
        [weak_self changGroupName:string];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - push To Info of contact
- (void)pushToContactInfo:(NSInteger )userId {
    
    InfoViewController *controller = [[InfoViewController alloc] init];
    controller.title = @"个人信息";
    if ([appDelegateAccessor.moudle.userId integerValue] == userId) {
        controller.infoTypeOfUser = InfoTypeMyself;
    }else{
        controller.infoTypeOfUser = InfoTypeOthers;
        controller.userId = userId;
    }
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark - 接口调用
//修改讨论组名
- (void)changGroupName:(NSString *)newName{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"userId"];
    [params setObject:newName forKey:@"name"];
    [params setObject:_groupID forKey:@"groupId"];
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_GROUP_NAME] params:params success:^(id responseObj) {
        NSLog(@"---- %@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if (_BlackGroupNewNameBlock) {
                _BlackGroupNewNameBlock(newName);
            }
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self changGroupName:newName];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        NSLog(@"-----%@", error);
    }];
}
//添加讨论组成员
- (void)addContactsForGroup:(NSArray *)array {
    //添加组成员  userId当前用户的id     ids除当前用户外的其他用户id    groupId增加人员的组id
    __weak typeof(self) weak_self = self;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    NSMutableArray *newAddIdsArray = [NSMutableArray arrayWithCapacity:0];
    for (ContactModel *model in array) {
        [newAddIdsArray addObject:@(model.userID)];
    }
    NSString *str = [newAddIdsArray componentsJoinedByString:@","];
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"userId"];
    [params setObject:str forKey:@"ids"];
    [params setObject:_groupID forKey:@"groupId"];
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_ADD_CONTACTS_GROUP] params:params success:^(id responseObj) {
        NSLog(@"-----%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            
            NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *oldArray = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_RecentContactList]];
            NSMutableArray *oldIdsArray = [NSMutableArray arrayWithCapacity:0];
            
            for (ContactModel *model in array) {
                [IM_FMDB_FILE insert_IM_UsersListListGroupID:_groupID withGroupType:_groupType withInfo:model];
            }
            if (weak_self.BlackContactArray) {
                weak_self.BlackContactArray(weak_self.contactArray);
            }
            //去重处理
            if (oldArray.count > 0) {
                for (ContactModel *oldModel in oldArray) {
                    [oldIdsArray addObject:@(oldModel.userID)];
                }
                for (ContactModel *model in array) {
                    if (![oldIdsArray containsObject:@(model.userID)]) {
                        [newArray addObject:model];
                    }
                }
            } else {
                [newArray addObjectsFromArray:array];
            }
            //合并数据
            newArray = (NSMutableArray *)[[newArray reverseObjectEnumerator] allObjects];
            oldArray = (NSMutableArray *)[[oldArray reverseObjectEnumerator] allObjects];
            
            [newArray addObjectsFromArray:oldArray];
            
            if (newArray && newArray.count > 5) {
                newArray  = [NSMutableArray arrayWithArray:[newArray subarrayWithRange:NSMakeRange(0, 5)]];
            }
            [IM_FMDB_FILE delete_IM_AllRecentContact];
            for (ContactModel *model in newArray) {
                if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                    [IM_FMDB_FILE insert_IM_RecentContact:model];
                }
            }
            [IM_FMDB_FILE closeDataBase];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self addContactsForGroup:array];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        NSLog(@"-----%@", error);
    }];
}
//删除讨论组成员、退出删除讨论组  type 0当前用户退出  1删除成员
- (void)deleteOneGroupWithType {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //    userId当前用户的id     userName当前用户名称    groupId增加人员的组id
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"userId"];
    [params setObject:appDelegateAccessor.moudle.userName forKey:@"userName"];
    [params setObject:_groupID forKey:@"groupId"];
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_DELETE_GROUP] params:params success:^(id responseObj) {
        NSLog(@"-----%@", responseObj);
        __weak typeof(self) weak_self = self;
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            [IM_FMDB_FILE delete_IM_OneConversationList:_groupID];
            [IM_FMDB_FILE delete_IM_OneGroupMessageList:_groupID];
            [IM_FMDB_FILE delete_IM_UsersListListGroupID:_groupID];
            [IM_FMDB_FILE closeDataBase];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getNewDataSourceOfGroupList" object:nil];
            [weak_self.navigationController popToRootViewControllerAnimated:YES];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self deleteOneGroupWithType];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        NSLog(@"-----%@", error);
    }];
}
- (void)getCreateGroup:(NSArray *)array {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableArray *idsArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *namesArray = [NSMutableArray arrayWithCapacity:0];
    for (ContactModel *model in array) {
        if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
            [idsArray addObject:@(model.userID)];
        }
        [namesArray addObject:model.contactName];
    }
    if (![namesArray containsObject:appDelegateAccessor.moudle.userName]) {
        [namesArray addObject:appDelegateAccessor.moudle.userName];
    }
    NSString *idsStr = [idsArray componentsJoinedByString:@","];
    NSString *nameStr = [namesArray componentsJoinedByString:@","];
    [params setObject:appDelegateAccessor.moudle.userId forKey:@"userId"];
    [params setObject:idsStr forKey:@"ids"];
    [params setObject:appDelegateAccessor.moudle.IM_tokenString forKey:@"token"];
    __weak typeof(self) weak_self = self;
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_IM, IM_GET_CREATE_GROUP] params:params success:^(id responseObj) {
        NSLog(@"----%@", responseObj);
        if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == 0) {
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"body"]]) {
                _groupType = [NSString stringWithFormat:@"%@", [[responseObj objectForKey:@"body"] objectForKey:@"type"]];
                _type = @"0";
                _groupName = nameStr;
            }
            [_tableViewAddOrDel reloadData];
            NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:0];
            NSArray *oldArray = [NSArray arrayWithArray:[IM_FMDB_FILE result_IM_RecentContactList]];
            NSMutableArray *oldIdsArray = [NSMutableArray arrayWithCapacity:0];
            
            //去重处理
            if (oldArray.count > 0) {
                for (ContactModel *model in _contactModelArray) {
                    if (model.userID == [appDelegateAccessor.moudle.userId integerValue]) {
                        [oldIdsArray addObject:@(model.userID)];
                    }
                }
                for (ContactModel *oldModel in oldArray) {
                    if (![oldIdsArray containsObject:@(oldModel.userID)]) {
                        [oldIdsArray addObject:@(oldModel.userID)];
                    }
                }
                for (ContactModel *model in array) {
                    if (![oldIdsArray containsObject:@(model.userID)]) {
                        [newArray addObject:model];
                    }
                }
            } else {
                [newArray addObjectsFromArray:array];
            }
            //合并数据
            newArray = (NSMutableArray *)[[newArray reverseObjectEnumerator] allObjects];
            oldArray = (NSMutableArray *)[[oldArray reverseObjectEnumerator] allObjects];
            
            [newArray addObjectsFromArray:oldArray];
            
            if (newArray && newArray.count > 5) {
                newArray  = [NSMutableArray arrayWithArray:[newArray subarrayWithRange:NSMakeRange(0, 5)]];
            }
            [IM_FMDB_FILE delete_IM_AllRecentContact];
            for (ContactModel *model in newArray) {
                if (model.userID != [appDelegateAccessor.moudle.userId integerValue]) {
                    [IM_FMDB_FILE insert_IM_RecentContact:model];
                }
            }
            [IM_FMDB_FILE closeDataBase];
            [weak_self.navigationController popToRootViewControllerAnimated:NO];
        } else if (responseObj && [[responseObj objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self getCreateGroup:array];
            };
            [comRequest loginInBackground];
        }
    } failure:^(NSError *error) {
        NSLog(@"----%@", error);
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([_type isEqualToString:@"1"] || [_groupType isEqualToString:@"0"]) {
        return 1;
    }
    return 4;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        if ([_type isEqualToString:@"0"]) {
            return _contactArray.count + 1;
        } else {
            return _contactArray.count + 2;
        }
    } else if (section == 1) {
        return 1;
    }else if (section == 2) {
        return 1;
    }else if (section == 3) {
        return 1;
    }
    return 0;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AddOrDeleteCollectionCell *cell = [[AddOrDeleteCollectionCell alloc] init];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddOrDeleteCollectionCellIdentifier" forIndexPath:indexPath];
        cell.deleteImgView.hidden = YES;
        cell.nameLabel.hidden = YES;
        if (indexPath.row < _contactArray.count) {
            cell.nameLabel.hidden = NO;
            ContactModel *item = _contactArray[indexPath.row];
            NSString *iconUrl = @"";
            if ([item.imgHeaderName hasPrefix:@"http"]) {
                iconUrl = item.imgHeaderName;
            } else {
                iconUrl = [NSString stringWithFormat:@"%@%@", GET_IM_ICON_URL, item.imgHeaderName];
            }
            [cell.iconImgView sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
            cell.nameLabel.text = item.contactName;
            if (_isDelete) {
                cell.deleteImgView.hidden = NO;
            } else {
                cell.deleteImgView.hidden = YES;
            }
        } else if (indexPath.row == _contactArray.count) {
            cell.iconImgView.image = [UIImage imageNamed:@"add-normal"];
        } else {
            cell.iconImgView.image = [UIImage imageNamed:@"minus-normal"];
        }
        cell.iconImgView.clipsToBounds = YES;
        cell.iconImgView.layer.masksToBounds = YES;
        cell.iconImgView.layer.cornerRadius = 5;
        cell.iconImgView.contentMode = UIViewContentModeScaleAspectFill;
        return cell;
    } else {
        InfoCollectionCell *cell = [[InfoCollectionCell alloc] init];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InfoCollectionCellIdentifier" forIndexPath:indexPath];
        if (indexPath.section == 1 ) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushViewController:)];
            [cell addGestureRecognizer:tap];
        }
        if (indexPath.section == 1) {
            cell.topicLabel.text = @"主题";
            if (_groupName && _groupName.length > 0) {
                cell.topicNameLabel.text = _groupName;
            } else{
                cell.topicNameLabel.text = @"未命名";
            }
            cell.topicLabel.hidden = NO;
            cell.topicNameLabel.hidden = NO;
            cell.groupNameLabel.hidden = YES;
            cell.showSwitch.hidden = YES;
            cell.deleteBtn.hidden = YES;
            cell.backgroundColor = [UIColor whiteColor];
        } else if (indexPath.section == 2) {
            cell.topicLabel.hidden = YES;
            cell.topicNameLabel.hidden = YES;
            cell.groupNameLabel.text = @"显示群成员昵称";
            cell.groupNameLabel.hidden = NO;
            NSString *show = [IM_FMDB_FILE result_IM_ShowOrHiddenContactName:_groupID];
            if ([show isEqualToString:@"1"]) {
                [cell.showSwitch setOn:YES animated:YES];
            }
            cell.showSwitch.hidden = NO;
            cell.deleteBtn.hidden = YES;
            cell.backgroundColor = [UIColor whiteColor];
        } else {
            cell.topicLabel.hidden = YES;
            cell.topicNameLabel.hidden = YES;
            cell.groupNameLabel.hidden = YES;
            cell.showSwitch.hidden = YES;
            cell.deleteBtn.hidden = NO;
            cell.deleteBtn.layer.masksToBounds = YES;
            cell.deleteBtn.layer.cornerRadius = 5;
            cell.deleteBtn.userInteractionEnabled = NO;
            [cell.deleteBtn setBackgroundColor:[UIColor colorWithHexString:@"ec5050"]];
        }
        
        return cell;
    }
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld %ld", indexPath.section, indexPath.row);
    [collectionView selectItemAtIndexPath:nil animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    if (indexPath.section == 0) {
        if (indexPath.row < _contactArray.count) {
            if (_isDelete) {
                if (_contactArray.count > 0) {
                    if (_contactArray.count == 2) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"最少为两个人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                        [alertView show];
                        return;
                    }
                    [_contactArray removeObjectAtIndex:indexPath.row];
                    if (_BlackContactArray) {
                        _BlackContactArray(_contactArray);
                    }

                    [_collcetionView reloadData];
                }
            } else {
                ContactModel *item = _contactArray[indexPath.row];
                [self pushToContactInfo:item.userID];
            }
        } else if (indexPath.row == _contactArray.count) {
            [self pushIntoAddressView];
        } else {
            _isDelete = !_isDelete;
            [_collcetionView reloadData];
        }
    } else if (indexPath.section == 3) {
        [self showActionSheet];
    } else {
        
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionReusableIdentifier" forIndexPath:indexPath];
    view.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
    return view;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeMake(kScreen_Width, 10);
    }
    return CGSizeMake(kScreen_Width, 20);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return CGSizeMake(60, 80);
    }
    return CGSizeMake(kScreen_Width, 44);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section == 0) {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)pushIntoAddressView {
    __weak typeof(self) weak_self = self;
    StartChatViewController *contactController = [[StartChatViewController alloc] init];
    contactController.title = @"通讯录";
    contactController.flag_controller = ControllerPopTypeBack;
    contactController.groupType = _groupType;
    contactController.GroupContactArray = _contactArray;
    [_addContactArray removeAllObjects];
    NSMutableArray *userIDArray = [NSMutableArray arrayWithCapacity:0];
    contactController.BackContactsBlock = ^(NSArray *itemsArray) {
        for (ContactModel *model  in _contactArray) {
            NSLog(@"%ld", model.userID);
            [userIDArray addObject:[NSString stringWithFormat:@"%ld", model.userID]];
        }
        for (ContactModel *item in itemsArray) {
            NSLog(@"是否包含%@----%ld", userIDArray, item.userID);
            if (![userIDArray containsObject:[NSString stringWithFormat:@"%ld", item.userID]]) {
                [_contactArray addObject:item];
                [_addContactArray addObject:item];
            }
        }
        if ([_type isEqualToString:@"0"]) {
            if ([_groupType isEqualToString:@"0"]) {
                [weak_self getCreateGroup:_contactArray];
            } else {
                if (_addContactArray.count > 0) {
                    [weak_self addContactsForGroup:_addContactArray];
                }
            }
        } else {
            if (_BlackContactArray) {
                _BlackContactArray(_contactArray);
            }
        }
        [_collcetionView reloadData];
    };
    [self.navigationController pushViewController:contactController animated:YES];

}
- (UICollectionView *)collcetionView {
    if (!_collcetionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collcetionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64) collectionViewLayout:layout];
        _collcetionView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
        _collcetionView.dataSource = self;
        _collcetionView.delegate = self;
        [_collcetionView registerNib:[UINib nibWithNibName:@"AddOrDeleteCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"AddOrDeleteCollectionCellIdentifier"];
        [_collcetionView registerNib:[UINib nibWithNibName:@"InfoCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"InfoCollectionCellIdentifier"];
        //注册页眉
        [_collcetionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionReusableIdentifier"];
        
    }
    return _collcetionView;
}
@end
