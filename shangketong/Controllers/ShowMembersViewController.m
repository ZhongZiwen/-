//
//  ShowMembersViewController.m
//  shangketong
//
//  Created by 蒋 on 15/8/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ShowMembersViewController.h"
#import "UITapImageView.h"
#import <UIImageView+WebCache.h>
#import <POPSpringAnimation.h>
//#import "AddressSelectModel.h"
//#import "AddressSelectMorePreModel.h"
//#import "AddressSelectMoreController.h"
#import "InfoViewController.h"
#import "CommonConstant.h"
#import "EditTextForDetailController.h"

#import "AFNHttp.h"
#import <MBProgressHUD.h>
#import "NSString+Common.h"

#define kSpaceWidth 15
#define kImageViewWidth (kScreen_Width - 6 * kSpaceWidth)/5.0
#define angelToRandian(x)  ((x)/180.0*M_PI)

@interface ShowMembersViewController ()

@end

@implementation ShowMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"举报" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    [self addCustomView];
    // Do any additional setup after loading the view from its nib.
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)backButtonPress {
    EditTextForDetailController *controller = [EditTextForDetailController new];
    controller.backTextViewValveBlock = ^(NSString *string) {
        NSLog(@"%@", string);
    };
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark - private method
- (void)addCustomView {
    NSArray *subviewsArr = [self.view subviews];
    [subviewsArr makeObjectsPerformSelector:@selector(removeFromSuperview)];
    /*
    for (int i = 0; i < [_memberModel.selectedArray count] + 2; i ++) {
        if (i < [_memberModel.selectedArray count]) {
            AddressSelectModel *item = _memberModel.selectedArray[i];
            UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(kSpaceWidth + (kImageViewWidth + kSpaceWidth) * (i % 5), 64 + 20 + (kImageViewWidth + kSpaceWidth + 20) * (i / 5), kImageViewWidth, kImageViewWidth + 20)];
            bgView.tag = 200 + i;
            bgView.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:bgView];

            UITapImageView *imageView = [[UITapImageView alloc] initWithFrame:CGRectMake(0, 0, kImageViewWidth, kImageViewWidth)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:item.m_icon] placeholderImage:[UIImage imageNamed:@"user_icon_default"]];
            imageView.tag = 300 + i;
            [imageView.layer setCornerRadius:5];
            imageView.clipsToBounds = YES;
            __weak typeof(self) weak_self = self;
            imageView.imageViewTapBlock = ^(NSInteger index) {
                NSLog(@"%ld", index);
                
                [weak_self pushToContactInfo:item.m_id];
            };
            [bgView addSubview:imageView];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, kImageViewWidth, kImageViewWidth, 20)];
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor grayColor];
            label.text = item.m_name;
            [bgView addSubview:label];
            
            UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteBtn.frame = CGRectMake(-6, -6, 20, 20);
            deleteBtn.tag = 400 + i;
            deleteBtn.hidden = YES;
            [deleteBtn setImage:[UIImage imageNamed:@"card_delete"] forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteBtnPress:) forControlEvents:UIControlEventTouchUpInside];
            [bgView addSubview:deleteBtn];
        }
        
        if (i == [_memberModel.selectedArray count]) {
            UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
            addButton.frame = CGRectMake(kSpaceWidth + (kImageViewWidth + kSpaceWidth) * (i % 5), 64 + 20 + (kImageViewWidth + kSpaceWidth + 20) * (i / 5), kImageViewWidth, kImageViewWidth);
            [addButton setImage:[UIImage imageNamed:@"add-normal"] forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(addButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:addButton];
        }
        
        if (i == [_memberModel.selectedArray count] + 1) {
            UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteButton.frame = CGRectMake(kSpaceWidth + (kImageViewWidth + kSpaceWidth) * (i % 5), 64 + 20 + (kImageViewWidth + kSpaceWidth + 20) * (i / 5), kImageViewWidth, kImageViewWidth);
            [deleteButton setImage:[UIImage imageNamed:@"minus-normal"] forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(deleteButtonPress:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:deleteButton];
        }
    }
     */
}
#pragma mark - event response
- (void)deleteBtnPress:(UIButton*)sender {
//    if (_memberModel.selectedArray.count == 1) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"参与人不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alertView show];
//        return;
//    }
//    AddressSelectModel *item = _memberModel.selectedArray[sender.tag - 400];
//    [_memberModel.selectedArray removeObject:item];
//    [self addCustomView];
//    if (_backMembersArrayBlock) {
//        _backMembersArrayBlock(_memberModel);
//    }
}

- (void)addButtonPress:(UIButton*)sender {
    __weak typeof(self) weak_self = self;
    
    /*
    AddressSelectMoreController *selectMoreController = [[AddressSelectMoreController alloc] init];
     NSMutableArray *userIDArray = [NSMutableArray arrayWithCapacity:0];
    selectMoreController.accessoryTypeFrom = AccessoryTypeFromSelectMorePre;
    selectMoreController.selectMoreBackBlock = ^(NSMutableArray *itemsArray) {
        for (AddressSelectModel *model  in _memberModel.selectedArray) {
            
            NSLog(@"%ld", model.m_id);
            [userIDArray addObject:[NSString stringWithFormat:@"%ld", model.m_id]];
        }
        NSLog(@"该任务的创建人-----%lld", _creataID);
        for (AddressSelectModel *contactModel in itemsArray) {
            //创建人不能为该任务的参与人，将创建人从参与人数组中剔除
            if (![userIDArray containsObject:[NSString stringWithFormat:@"%ld", contactModel.m_id]] && _creataID != contactModel.m_id) {
                [_memberModel.selectedArray addObject:contactModel];
            }
        }
        
        [weak_self  addCustomView];
        if (_backMembersArrayBlock) {
            _backMembersArrayBlock(_memberModel);
        }
        
    };
    [self.navigationController pushViewController:selectMoreController animated:YES];
     */
}

- (void)deleteButtonPress:(UIButton*)sender {
//    for (int i = 0; i < _memberModel.selectedArray.count; i ++) {
//        UIButton *button = (UIButton*)[self.view viewWithTag:400 + i];
//        button.hidden = !button.hidden;
//    }
}

- (CAKeyframeAnimation*)rotationAnimation {
    CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
    anim.keyPath=@"transform.rotation";
    anim.values=@[@(angelToRandian(-4)),@(angelToRandian(4)),@(angelToRandian(-4))];
    anim.repeatCount=MAXFLOAT;
    anim.duration=0.2;
    return anim;
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
