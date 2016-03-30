//
//  EditInfoViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "EditInfoViewController.h"
#import <TPKeyboardAvoidingTableView.h>
#import "EditHeaderTableViewCell.h"
#import "EditTitleValueTableViewCell.h"
#import "CommonConstant.h"
#import <MBProgressHUD.h>
#import "CommonFuntion.h"
#import "AFNHttp.h"
#import "AFHTTPRequestOperationManager.h"

#define kCellIdentifier @"EditTitleValueTableViewCell"
#define kCellIdentifier_Header @"EditHeaderTableViewCell"

@interface EditInfoViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    NSArray *sourceArray;
    
    NSString *userName;
    ///职位
    NSString *userPost;
    ///邮箱
    NSString *userEmail;
    ///手机
    NSString *userMobile;
    ///电话
    NSString *userPhone;
    ///分机
    NSString *userExtension;
    ///自我介绍
    NSString *userSelfIntro;
    ///业务专长
    NSString *userExpertise;
    
    ///头像是否做了修改
    BOOL isEditIcon;
    
    NSMutableArray *arrayContactWay;
}

@property (nonatomic, weak) TPKeyboardAvoidingTableView *m_tableView;

@end

@implementation EditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    userIcon = [UIImage imageNamed:PLACEHOLDER_REVIEW_IMG];
    isEditIcon = NO;
    userName = @"";
    userPost = @"";
    userMobile = @"";
    userPhone = @"";
    userExtension = @"";
    userSelfIntro = @"";
    userExpertise = @"";
    
    arrayContactWay = [[NSMutableArray alloc] init];
    NSDictionary *item;
    if (self.userInfo) {
        
        ///邮箱未绑定
        if ([[self.userInfo safeObjectForKey:@"emailBound"] integerValue] == 0) {
            item = [NSDictionary dictionaryWithObjectsAndKeys:@"邮箱",@"title", nil];
            [arrayContactWay addObject:item];
        }
        
        ///手机未验证
        if ([[self.userInfo safeObjectForKey:@"mobileBound"] integerValue] == 0) {
            item = [NSDictionary dictionaryWithObjectsAndKeys:@"手机",@"title", nil];
            [arrayContactWay addObject:item];
        }
        
        item = [NSDictionary dictionaryWithObjectsAndKeys:@"电话",@"title", nil];
        [arrayContactWay addObject:item];
        item = [NSDictionary dictionaryWithObjectsAndKeys:@"分机",@"title", nil];
        [arrayContactWay addObject:item];
    }
    
    sourceArray = @[@[@{@"title":@"姓名"},
                      @{@"title":@"职位"}],
                    arrayContactWay,
                    @[@{@"title":@"自我介绍"},
                      @{@"title":@"业务专长"}]];
    
    if (self.userInfo) {
//        userIcon = [UIImage imageNamed:[self.userInfo safeObjectForKey:@"icon"]];
        userName = [self.userInfo safeObjectForKey:@"name"];
        userPost = [self.userInfo safeObjectForKey:@"post"];
        userMobile = [self.userInfo safeObjectForKey:@"mobile"];
        userPhone = [self.userInfo safeObjectForKey:@"phone"];
        userExtension = [self.userInfo safeObjectForKey:@"extension"];
        userSelfIntro = [self.userInfo safeObjectForKey:@"selfIntro"];
        userExpertise = [self.userInfo safeObjectForKey:@"expertise"];
        userEmail = [self.userInfo safeObjectForKey:@"email"];
    }
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonPress)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    TPKeyboardAvoidingTableView *tableView = [[TPKeyboardAvoidingTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[EditHeaderTableViewCell class] forCellReuseIdentifier:kCellIdentifier_Header];
    [tableView registerClass:[EditTitleValueTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorColor = COLOR_TABLEVIEW_SEPARATOR_LINE;
    tableView.backgroundColor = COMMEN_VIEW_BACKGROUNDCOLOR;
    [self.view addSubview:tableView];
    _m_tableView = tableView;
}


#pragma mark - 保存操作
- (void)saveButtonPress
{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    NSLog(@"saveButtonPress");
    
    NSLog(@"userName:%@",userName);
    NSLog(@"userPost:%@",userPost);
    NSLog(@"userEmail:%@",userEmail);
    NSLog(@"userMobile:%@",userMobile);
    NSLog(@"userPhone:%@",userPhone);
    NSLog(@"userExtension:%@",userExtension);
    NSLog(@"userSelfIntro:%@",userSelfIntro);
    NSLog(@"userExpertise:%@",userExpertise);
    
    NSLog(@"usericon:%@",self.userIcon);
    
    if ([self isValidInputStr]) {
        [self sendCmdUpdateUserInfo];
    }
}

///输入是否有效  ?哪些可为空
-(BOOL)isValidInputStr{
    /*
    if (self.userIcon == nil || [self.userIcon isEqual:[NSNull null]] ) {
        kShowHUD(@"请选择头像")
        return  NO;
    }
    */
    
    if ([CommonFuntion isEmptyString:userName]) {
        [CommonFuntion showToast:@"请输入姓名" inView:self.view];
        return  NO;
    }
    
    
    if (userName.length > 30) {
        [CommonFuntion showToast:@"姓名长度最大为30" inView:self.view];
        return  NO;
    }
    
    if (userPost.length > 15) {
        [CommonFuntion showToast:@"职位长度最大为15" inView:self.view];
        return  NO;
    }
    
    
    if (userEmail.length > 30) {
        [CommonFuntion showToast:@"邮箱长度最大为30" inView:self.view];
        return  NO;
    }
    
    if(![NSString isValidateEmail:userEmail]){
        [CommonFuntion showToast:@"请输入正确格式的邮箱" inView:self.view];
        return  NO;
    }

    
    if (![CommonFuntion isEmptyString:userMobile] && (userMobile.length > 11  || ![CommonFuntion checkStringIsAllow:userMobile withChar:CHECK_CHAR_PHONE_NUM])) {
        [CommonFuntion showToast:@"请输入正确的手机号码" inView:self.view];
        return  NO;
    }
    
    
    if (![CommonFuntion isEmptyString:userPhone] && userPhone.length > 12) {
        [CommonFuntion showToast:@"电话号码长度最大为12位" inView:self.view];
        return NO;
    }
    
    
    if (![CommonFuntion isEmptyString:userPhone] && ![CommonFuntion checkStringIsAllow:userPhone withChar:CHECK_CHAR_PHONE_NUM]) {
        [CommonFuntion showToast:@"请输入正确的电话号码" inView:self.view];
        return  NO;
    }
    
    
    if (![CommonFuntion isEmptyString:userExtension]) {
        
        if ([CommonFuntion isEmptyString:userPhone]) {
            [CommonFuntion showToast:@"请输入电话号码" inView:self.view];
            return NO;
        }
        
        if (userExtension.length > 4) {
            [CommonFuntion showToast:@"分机号为4位数字" inView:self.view];
            return NO;
        }
        
        if (![CommonFuntion checkStringIsAllow:userExtension withChar:CHECK_CHAR_PHONE_NUM]) {
            [CommonFuntion showToast:@"请输入正确的分机号码" inView:self.view];
            return  NO;
        }
    }
    
    
    if (![CommonFuntion isEmptyString:userSelfIntro] && userSelfIntro.length > 150) {
        [CommonFuntion showToast:@"自我介绍最大长度为150" inView:self.view];
        return  NO;
    }
    
    if (![CommonFuntion isEmptyString:userExpertise] && userExpertise.length > 150) {
        [CommonFuntion showToast:@"业务专长最大长度为150" inView:self.view];
        return  NO;
    }
    
    return YES;
}


#pragma mark - 更新个人资料
-(void)sendCmdUpdateUserInfo{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    ///更新联系人资料   name（名字）,post（职位）,email(没有验证的话传入),mobile(没有验证的话传入),phone（电话）,extension（分机）,intro（个人介绍）,expertise（特长）,userIcon（头像）
    
   
    NSData *imageData = UIImageJPEGRepresentation(self.userIcon, 0.3);
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    [params setObject:[userName stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"name"];
    [params setObject:userPost forKey:@"post"];
    [params setObject:userPhone forKey:@"phone"];
    [params setObject:userExtension forKey:@"extension"];
    [params setObject:userSelfIntro forKey:@"intro"];
    [params setObject:userExpertise forKey:@"expertise"];

    
    ///没有验证的话传入
    if (self.userInfo && [[self.userInfo safeObjectForKey:@"emailBound"] integerValue] == 0) {
        [params setObject:userEmail forKey:@"email"];
    }
    
    ///没有验证的话传入
    if (self.userInfo && [[self.userInfo safeObjectForKey:@"mobileBound"] integerValue] == 0) {
        [params setObject:userMobile forKey:@"mobile"];
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"text/plain", nil];
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    [manager POST:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,UPDATE_CONTACT_INFO_ACTION] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (isEditIcon) {
//            NSLog(@"更新头像---->");
            ///图片
            [formData appendPartWithFileData :imageData name:@"userIcon" fileName:@"icon.jpeg" mimeType:@"image/jpeg"];
        }
        
    } success:^(AFHTTPRequestOperation *operation,id responseObject) {
        [hud hide:YES];
        
        NSLog(@"更新个人资料 responseObj:%@",responseObject);
        if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
            NSDictionary *userInfo = responseObject ;
            if (self.UpdateUserInfosBlock) {
                self.UpdateUserInfosBlock(userInfo);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == STATUS_SESSION_UNAVAILABLE) {
            __weak typeof(self) weak_self = self;
            CommonLoginEvent *comRequest = [[CommonLoginEvent alloc] init];
            comRequest.RequestAgainBlock = ^(){
                [weak_self sendCmdUpdateUserInfo];
            };
            [comRequest loginInBackground];
        }else{
            NSString *desc = [responseObject safeObjectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"编辑资料失败";
            }
            NSLog(@"desc:%@",desc);
            [CommonFuntion showToast:desc inView:self.view];
        }
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        [hud hide:YES];
        [CommonFuntion showToast:@"编辑资料失败" inView:self.view];
        
        NSLog ( @"operation: %@" , operation. responseString );
        NSLog(@"error:%@",error);
        
    }];
}


#pragma mark - scrollView
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark - UITableView_M
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return [arrayContactWay count];
            break;
        case 3:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [EditHeaderTableViewCell cellHeight];
    }
    return [EditTitleValueTableViewCell cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        EditHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Header forIndexPath:indexPath];
//        NSString *icon = @"";
//        if (self.userInfo) {
//            icon = [self.userInfo safeObjectForKey:@"icon"];
//        }
        [cell setTitleLabel:@"头像" headerImageView:self.userIcon];
        [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.0];
        return cell;
    }
    
    EditTitleValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    NSString *titleStr = [[[sourceArray objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    cell.m_textField.keyboardType = UIKeyboardTypeDefault;
    NSString *valueStr = @"";
    
    
    if ([titleStr isEqualToString:@"姓名"]) {
        valueStr = userName;
    }else if ([titleStr isEqualToString:@"职位"]) {
        valueStr = userPost;
    }if ([titleStr isEqualToString:@"邮箱"]) {
        valueStr = userEmail;
    }if ([titleStr isEqualToString:@"手机"]) {
        valueStr = userMobile;
        cell.m_textField.keyboardType = UIKeyboardTypeNumberPad;
    }if ([titleStr isEqualToString:@"电话"]) {
        valueStr = userPhone;
        cell.m_textField.keyboardType = UIKeyboardTypeNumberPad;
    }if ([titleStr isEqualToString:@"分机"]) {
        valueStr = userExtension;
        cell.m_textField.keyboardType = UIKeyboardTypeNumberPad;
    }if ([titleStr isEqualToString:@"自我介绍"]) {
        valueStr = userSelfIntro;
    }if ([titleStr isEqualToString:@"业务专长"]) {
        valueStr = userExpertise;
    }
    
    
    
//    if (indexPath.section == 1 && indexPath.row == 0) {
//        valueStr = userName;
//    }else if (indexPath.section == 1 && indexPath.row == 1) {
//        valueStr = userPost;
//    }else if (indexPath.section == 2 && indexPath.row == 0) {
//        valueStr = userMobile;
//        cell.m_textField.keyboardType = UIKeyboardTypeNumberPad;
//    }else if (indexPath.section == 2 && indexPath.row == 1) {
//        valueStr = userPhone;
//        cell.m_textField.keyboardType = UIKeyboardTypeNumberPad;
//    }else if (indexPath.section == 2 && indexPath.row == 2) {
//        valueStr = userExtension;
//        cell.m_textField.keyboardType = UIKeyboardTypeNumberPad;
//    }else if (indexPath.section == 3 && indexPath.row == 0) {
//        valueStr = userSelfIntro;
//    }else if (indexPath.section == 3 && indexPath.row == 1) {
//        valueStr = userExpertise;
//    }
    
    
    cell.textValueChangedBlock = ^(NSString *valueStr) {
        NSLog(@"%@", valueStr);
//        if (indexPath.section == 1 && indexPath.row == 0) {
//            userName = valueStr;
//        }else if (indexPath.section == 1 && indexPath.row == 1) {
//            userPost = valueStr;
//        }else if (indexPath.section == 2 && indexPath.row == 0) {
//            userMobile = valueStr;
//        }else if (indexPath.section == 2 && indexPath.row == 1) {
//            userPhone = valueStr;
//        }else if (indexPath.section == 2 && indexPath.row == 2) {
//            userExtension = valueStr;
//        }else if (indexPath.section == 3 && indexPath.row == 0) {
//            userSelfIntro = valueStr;
//        }else if (indexPath.section == 3 && indexPath.row == 1) {
//            userExpertise = valueStr;
//        }
        
        
        if ([titleStr isEqualToString:@"姓名"]) {
            userName = valueStr;
        }else if ([titleStr isEqualToString:@"职位"]) {
            userPost = valueStr;
        }if ([titleStr isEqualToString:@"邮箱"]) {
            userEmail= valueStr;
        }if ([titleStr isEqualToString:@"手机"]) {
            userMobile = valueStr;
        }if ([titleStr isEqualToString:@"电话"]) {
            userPhone = valueStr;
        }if ([titleStr isEqualToString:@"分机"]) {
            userExtension = valueStr;
        }if ([titleStr isEqualToString:@"自我介绍"]) {
            userSelfIntro = valueStr;
        }if ([titleStr isEqualToString:@"业务专长"]) {
            userExpertise = valueStr;
        }
        
        
    };
    [cell setTitleLabel:titleStr valueLabel:valueStr];
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:10.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"更换头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相册中选择", nil];
        [actionSheet showInView:kKeyWindow];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;//设置可编辑
    
    if (buttonIndex == 0) {
        //        拍照
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if (buttonIndex == 1){
        //        相册
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:picker animated:YES completion:nil];//进入照相界面
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
#warning 待处理？
    isEditIcon = YES;
    UIImage *editedImage, *originalImage;
    self.userIcon = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [self.m_tableView reloadData];
    // 上传服务器
    
    // 保存原图片到相册中
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
        UIImageWriteToSavedPhotosAlbum(originalImage, self,selectorToCall, NULL);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
        NSLog(@"Error = %@", paramError);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
