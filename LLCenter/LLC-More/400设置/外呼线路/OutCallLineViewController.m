//
//  OutCallLineViewController.m
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "OutCallLineViewController.h"
#import "CommonFunc.h"
#import "LLCenterUtility.h"

@interface OutCallLineViewController (){
    ///phone  双线
    ///intnet 单线
    
    ///当前选择的线路
    NSString *curWay;
    NSString *curSelectWay;
    
    ///是否处于编辑状态
    BOOL isEditing;
}

@end

@implementation OutCallLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"外呼线路";
    isEditing = FALSE;
    [super customBackButton];
    self.view.backgroundColor = COLOR_BG;
    [self addNarBar];
    [self intViewFrame];

    ///默认
    curWay = @"phone";
    self.btnOneWay.enabled = NO;
    self.btnTwoWay.enabled = NO;
    
    [self findOutboundRouteType];
}


///单向
- (IBAction)selectOneWay:(id)sender {
    curSelectWay = @"intnet";
    
    [self.btnOneWay setImage:[UIImage imageNamed:@"img_select_selected.png"] forState:UIControlStateNormal];
    [self.btnTwoWay setImage:[UIImage imageNamed:@"img_select_unselect.png"] forState:UIControlStateNormal];
}


///双向
- (IBAction)selectTwoWay:(id)sender {
    curSelectWay = @"phone";
    
    [self.btnTwoWay setImage:[UIImage imageNamed:@"img_select_selected.png"] forState:UIControlStateNormal];
    [self.btnOneWay setImage:[UIImage imageNamed:@"img_select_unselect.png"] forState:UIControlStateNormal];
}


-(void)notifySelect{
    
    if ([curWay isEqualToString:@"phone"]) {
        [self.btnTwoWay setImage:[UIImage imageNamed:@"img_select_selected.png"] forState:UIControlStateNormal];
        [self.btnOneWay setImage:[UIImage imageNamed:@"img_select_unselect.png"] forState:UIControlStateNormal];
    }else{
        [self.btnOneWay setImage:[UIImage imageNamed:@"img_select_selected.png"] forState:UIControlStateNormal];
        [self.btnTwoWay setImage:[UIImage imageNamed:@"img_select_unselect.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - Nar Bar
-(void)addNarBar{
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = rightButton;
}


#pragma mark-  保存事件
-(void)saveButtonPress {
    
    if (isEditing) {
        if (![CommonFunc checkNetworkState]) {
            [CommonFuntion showToast:@"无网络可用,加载失败" inView:self.view];
            return;
        }
        [self updateOutboundRouteType];
    }else{
        isEditing = TRUE;
        self.btnOneWay.enabled = YES;
        self.btnTwoWay.enabled = YES;
        self.navigationItem.rightBarButtonItem.title = @"保存";
    }
}


#pragma mark - 请求服务器数据
///获取外呼线路状态接口
-(void)findOutboundRouteType{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:nil];
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_GET_OUTBOUND_ROUTE_TYPE_ACTION] params:params success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"外呼线路状态jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            
            if ([[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"] != [NSNull null]) {
                curWay = [[jsonResponse objectForKey:@"resultMap"] objectForKey:@"data"];
                [self notifySelect];
            }else{
                NSLog(@"data------>:<null>");
                [CommonFuntion showToast:@"加载异常" inView:self.view];
            }
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self findOutboundRouteType];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"加载失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}


#pragma mark - 设置外呼线路接口
-(void)updateOutboundRouteType{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    ///传入：外呼线路类型（单向还是双向）
    ///传入：circuit
    NSMutableDictionary *rDict = [NSMutableDictionary dictionaryWithDictionary:nil];
    [rDict setValue:curSelectWay forKey:@"circuit"];
    
    NSString *jsonString = [[NSString alloc] initWithData:[CommonFunc toJSONData:rDict]
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString:%@",jsonString);
    
    ///dic转换为json
    NSMutableDictionary *rParam = [NSMutableDictionary dictionaryWithDictionary:nil];
    
    [rParam setObject:jsonString forKey:@"data"];
    
    
    // 发起请求
    [AFNHttp post:[NSString stringWithFormat:@"%@%@",LLC_SERVER_IP,LLC_EDIT_OUTBOUND_ROUTE_TYPE_ACTION] params:rParam success:^(id jsonResponse) {
        [hud hide:YES];
        
        NSLog(@"修改外呼线路接口jsonResponse:%@",jsonResponse);
        if ([[jsonResponse objectForKey:@"status"] intValue] == 1) {
            [CommonFuntion showToast:@"编辑成功" inView:self.view];
            curWay = curSelectWay;
            isEditing = FALSE;
            self.navigationItem.rightBarButtonItem.title = @"编辑";
            self.btnOneWay.enabled = FALSE;
            self.btnTwoWay.enabled = FALSE;
            
        }else if ([[jsonResponse objectForKey:@"status"] intValue] == 2) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self updateOutboundRouteType];
            };
            [comRequest loginInBackgroundLLC];
        }
        else {
            //获取失败
            NSString *desc = [jsonResponse safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"编辑失败";
            }
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:LLC_NET_ERROR inView:self.view];
    }];
}


#pragma mark - frmae
-(void)intViewFrame{
    
    NSInteger vX = (DEVICE_BOUNDS_WIDTH-320)/2;
    
    NSString *onewayTitleRM = @"说明:   单向PSTN外呼拨打,通话效果较好,较稳定.";
    CGSize sizeOneWayTitleRM = [CommonFunc getSizeOfContents:onewayTitleRM Font:[UIFont systemFontOfSize:13.0] withWidth:DEVICE_BOUNDS_WIDTH-10 withHeight:2999];
    
    self.btnOneWay.frame = [CommonFunc setViewFrameOffset:self.btnOneWay.frame byX:vX byY:0 ByWidth:0 byHeight:0];
//    self.labelOneWayTitle.frame = [CommonFunc setViewFrameOffset:self.labelOneWayTitle.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    self.labelOneWayReadMe.frame = CGRectMake(5, 80, DEVICE_BOUNDS_WIDTH-10, sizeOneWayTitleRM.height);
    
    self.imgLine.frame = [CommonFunc setViewFrameOffset:self.imgLine.frame byX:0 byY:0 ByWidth:vX*2 byHeight:0];
    
    NSString *twowayTitleRM = @"说明:   双向PSTN外呼拨打,通话效果好,稳定.费用比单向PSTN线路较高.";
    CGSize sizeTwoWayTitleRM = [CommonFunc getSizeOfContents:twowayTitleRM Font:[UIFont systemFontOfSize:13.0] withWidth:DEVICE_BOUNDS_WIDTH-10 withHeight:2999];
    self.btnTwoWay.frame = [CommonFunc setViewFrameOffset:self.btnTwoWay.frame byX:vX byY:0 ByWidth:0 byHeight:0];
//    self.labelTwoWayTitle.frame = [CommonFunc setViewFrameOffset:self.labelTwoWayTitle.frame byX:vX byY:0 ByWidth:0 byHeight:0];
    self.labelTwoWayReadMe.frame = CGRectMake(5, 178, DEVICE_BOUNDS_WIDTH-10, sizeTwoWayTitleRM.height);
    
    self.imgLine2.frame = [CommonFunc setViewFrameOffset:self.imgLine2.frame byX:0 byY:0 ByWidth:vX*2 byHeight:0];
//    self.imgLine2.hidden = YES;
}


@end
