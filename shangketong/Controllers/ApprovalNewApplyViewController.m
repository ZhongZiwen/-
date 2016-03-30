//
//  ApprovalNewApplyViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/31.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalNewApplyViewController.h"
#import "WRNewItem.h"
#import <XLForm.h>
#import "XLFTextValueCell.h"
#import "XLFSelectorTextDetailCell.h"
#import "XLFSelectorTextImageCell.h"
#import "XLFormCustomDateCell.h"
#import "AddressBook.h"
#import "ExportAddress.h"
#import "EditAddressViewController.h"
#import "ExportAddressViewController.h"
#import "AddressSelectedController.h"
#import <MBProgressHUD.h>
#import "AFNHttp.h"
#import "SBJson.h"
#import "AFHTTPRequestOperationManager.h"
#import "ApprovalSelectViewController.h"
#import "RelatedBusinessController.h"
#import "XLFormCustomTextViewCell.h"
#import "XLFormCustomImageCell.h"
#import "PhotoAssetModel.h"
#import "NSUserDefaults_Cache.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "DateAndTimeValueTrasformer.h"

#import "PhotoAssetLibraryViewController.h"
#import "PhotoAssetModel.h"
#import <POP.h>
//#import "PhotoBrowserViewController.h"

static NSString *const kApproval = @"approval";
static NSString *const kCopys = @"copys";
static NSString *const kChoiceFile = @"choiceFile";        // 选择图片附件
static NSString *const kRelevance = @"relevance";        // 关联业务

@interface ApprovalNewApplyViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, XLFormDescriptorDelegate>{
    UIImage  *imgData;
}

@property (nonatomic, copy) void(^RefreshBussineBlock)(NSDictionary *);

@property (nonatomic, strong) PhotoAssetLibraryViewController *assetLibraryController;

@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, strong) NSMutableArray *ccUsers;
@property (nonatomic, strong) NSMutableArray *reviewers;
@property (nonatomic, strong) NSDictionary *titleDict;
@property (nonatomic, assign) NSInteger assignable;
@property (nonatomic, assign) NSInteger uploadFile;
///是否显示
@property (nonatomic, assign) NSInteger hasFile;

///
@property (nonatomic, assign) NSInteger hasRelevance;///是否有关联业务
@property (nonatomic, assign) NSInteger relevanceRequired;///关联业务是否必选
///关联业务code
@property (nonatomic, strong) NSString *businessCode;
@property (nonatomic, strong) NSString *selectImgName; //所选图片的名称




- (void)assignReveiwer;
@end

@implementation ApprovalNewApplyViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //关联业务
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationRefresh:) name:@"relatedBusiness" object:nil];
}

- (void)notificationRefresh:(NSNotification *)notification {
    if (_RefreshBussineBlock) {
        _RefreshBussineBlock([notification object]);
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    imgData = nil;
    _sourceArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    self.form = form;
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@(_applyId) forKey:@"id"];
    [params setObject:@(_applyTypeId) forKey:@"typeId"];

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    [AFNHttp post:[NSString stringWithFormat:@"%@%@", MOBILE_SERVER_IP_OA, kNetPath_Approve_Application] params:params success:^(id responseObj) {
        [hud hide:YES];
        NSLog(@"新建审批 = %@", responseObj);
        if (![[responseObj objectForKey:@"status"] integerValue]) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            NSDictionary *userInfo = [NSUserDefaults_Cache getUserInfo];
            
            
            _titleDict = [NSDictionary dictionaryWithObjectsAndKeys:responseObj[@"flowName"], @"text", [NSString stringWithFormat:@"申请人：%@", [userInfo safeObjectForKey:@"name"]], @"value", @0, @"isEdit", nil];
            // 获取抄送人
            _ccUsers = [[NSMutableArray alloc] initWithArray:responseObj[@"ccUsers"]];
            // 获取审批人
            _reviewers = [[NSMutableArray alloc] initWithArray:responseObj[@"reveiwers"]];
            // 获取组建表格数据
            for (NSDictionary *tempDict in responseObj[@"columns"]) {
                WRNewItem *item = [WRNewItem initWithDictionary:tempDict];
                [_sourceArray addObject:item];
            }
            _assignable = [responseObj[@"assignable"] integerValue];
            _uploadFile = [responseObj[@"uploadFile"] integerValue];
             _hasFile = [responseObj[@"hasFile"] integerValue];
            _hasRelevance = [responseObj[@"relevance"] integerValue];
            _relevanceRequired = [responseObj[@"relevanceRequired"] integerValue];
            if ([CommonFuntion checkNullForValue:[responseObj objectForKey:@"businessCode"]]) {
                _businessCode = [responseObj safeObjectForKey:@"businessCode"];
            } else {
                _businessCode = @"";
            }
            
            [self createXLForm];
        }
    } failure:^(NSError *error) {
        [hud hide:YES];

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event response
- (void)rightButtonItemPress {
    // 参数：reviewerId(审批人id),ccUserIds(抄送人id,以逗号分隔), json(propertyName，object，result)   如果是编辑 ： 需要传 id   审批id    customId  审批扩展id
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    XLFormRowDescriptor *row;

    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    
    row = [self.form formRowWithTag:kApproval];
    if (![[(NSDictionary*)row.value objectForKey:@"uid"] length]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请选择一个审批人" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [params setObject:[(NSDictionary*)row.value objectForKey:@"uid"] forKey:@"reviewerId"];
    
    // 获取抄送人
    row = [self.form formRowWithTag:kCopys];
    // 先将抄送人中有批阅人给过滤掉
    NSString *copysString = @"";
    NSArray *copysArray = [[row.value formValue] componentsSeparatedByString:@","];
    for (int i = 0; i < copysArray.count; i ++) {
        NSString *copyIdStr = copysArray[i];
        if ([copyIdStr isEqualToString:params[@"reviewerId"]])
            continue;
        if (i == 0) {
            copysString = [NSString stringWithFormat:@"%@", copyIdStr];
        }else {
            copysString = [NSString stringWithFormat:@"%@,%@", copysString, copyIdStr];
        }
    }
    [params setObject:copysString forKey:@"ccUserIds"];
    
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (WRNewItem *item in _sourceArray) {
        row = [self.form formRowWithTag:item.m_name];
        if (item.m_columnType == 3) {   // 单选
            XLFormOptionsObject *optionsObject = row.value;
            if (!item.m_required) {
                if (optionsObject) {
                    [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                           @"object" : item.m_object,
                                           @"result" : optionsObject.formValue,
                                           @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
                }else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", item.m_name] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                    return;
                }
            }else {
                [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                       @"object" : item.m_object,
                                       @"result" : (optionsObject ? optionsObject.formValue : @""),
                                       @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
            }
        }else if (item.m_columnType == 4) {     // 多选
            NSString *objectString = @"";
            for (int i = 0; i < [row.value count]; i ++) {
                XLFormOptionsObject *optionsObject = row.value[i];
                if (i == 0) {
                    objectString = [NSString stringWithFormat:@"%@", optionsObject.formValue];
                }else {
                    objectString = [NSString stringWithFormat:@"%@,%@", objectString, optionsObject.formValue];
                }
            }
            if (!item.m_required) {
                if (![objectString length]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", item.m_name] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                    return;
                }
            }
            [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                   @"object" : item.m_object,
                                   @"result" : objectString,
                                   @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
        }else if (item.m_columnType == 7) {     // 日期
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            if (!item.m_fullDate) {
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            }else{
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            }
            
            NSString *string = [dateFormatter stringFromDate:row.value];
            if (!item.m_required) {
                if (!string) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", item.m_name] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                    return;
                }
            }
            [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                   @"object" : item.m_object,
                                   @"result" : (string ? string : @""),
                                   @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
        }else {     // 其它
            
            if (!item.m_required) {
                if (!row.value) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@不能为空", item.m_name] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alertView show];
                    return;
                }
            }
            [jsonArray addObject:@{@"propertyName" : item.m_propertyName,
                                   @"object" : item.m_object,
                                   @"result" : (row.value ? row.value : @""),
                                   @"columnType" : [NSNumber numberWithInteger:item.m_columnType]}];
        }
    }
    
    
    ///关联业务是否必选
    if (!_relevanceRequired) {
        row = [self.form formRowWithTag:kRelevance];
        NSLog(@"row.value:%@",row.value);
        if (row.value && [row.value objectForKey:@"businessId"] && [[row.value objectForKey:@"businessId"] length] > 0 ) {
            if ([[row.value allKeys] containsObject:@"businessType"]) {
                [params setObject:[row.value objectForKey:@"businessType"] forKey:@"businessType"]; //业务类型
            }
            if ([[row.value allKeys] containsObject:@"businessId"]) {
                [params setObject:[row.value objectForKey:@"businessId"] forKey:@"businessId"]; //业务id
            }
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请选择关联业务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            return;
        }
    } else {
        row = [self.form formRowWithTag:kRelevance];
        NSLog(@"row.value:%@",row.value);
        if (row.value && [row.value objectForKey:@"businessId"] && [[row.value objectForKey:@"businessId"] length] > 0 ) {
            if ([[row.value allKeys] containsObject:@"businessType"]) {
                [params setObject:[row.value objectForKey:@"businessType"] forKey:@"businessType"]; //业务类型
            }
            if ([[row.value allKeys] containsObject:@"businessId"]) {
                [params setObject:[row.value objectForKey:@"businessId"] forKey:@"businessId"]; //业务id
            }
        }
    }
    
    ///图片附件为必填
    row = [self.form formRowWithTag:kChoiceFile];
    if (!_hasFile) {
        if (!_uploadFile && !row.value) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请选择图片附件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            return;
        }
    }
    
    
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
    NSString *jsonString =[jsonParser stringWithObject:jsonArray];
    [params setObject:jsonString forKey:@"json"];
    NSLog(@"----组装结果-----%@", params);
    
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    __weak __block typeof(self) weak_self = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"text/plain", nil];
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,kNetPath_Approve_Submit] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        ///图片 uploadFile
        if (row.value) {
            PhotoAssetModel *item = row.value;
            NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:[[item.asset defaultRepresentation] fullScreenImage]], 1.0);
            if ((float)imageData.length/1024 > 1000) {
                imageData = UIImageJPEGRepresentation([UIImage imageWithCGImage:[[item.asset defaultRepresentation] fullScreenImage]], 1024*1000.0/(float)imageData.length);
            }
            if (imageData) {
                ALAssetRepresentation *representation = [item.asset defaultRepresentation];
                NSString *imageName = [representation filename];
                [formData appendPartWithFileData:imageData name:@"uploadFile" fileName:[NSString stringWithFormat:@"%@.jpeg", [CommonFuntion getFileNameDeleteEctension:imageName]] mimeType:@"image/jpeg"];
            }
        }
    } success:^(AFHTTPRequestOperation *operation,id responseObject) {
        [hud hide:YES];
        NSLog(@"desc:%@",[responseObject objectForKey:@"desc"]);
        if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
            if (self.refreshBlock) {
                self.refreshBlock();
            }
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
        }else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
            NSString *desc = @"";
            desc = [responseObject objectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"提交失败";
            }
            kShowHUD(desc,nil)
        }
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        NSLog(@"error:%@",error);
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [hud hide:YES];
        kShowHUD(NET_ERROR)
        NSLog ( @"operation: %@" , operation. responseString );
        NSLog(@"error:%@",error);
    }];
}


- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

// 限制textField字数
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > MAX_LIMIT_TEXTFIELD) {
        textField.text = [textField.text substringToIndex:MAX_LIMIT_TEXTFIELD];
    }
}

- (void)createXLForm {
    
    __typeof(self) __weak weakSelf = self;

    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeTextValue];
    row.value = _titleDict;
    [row.cellConfig setObject:[UIFont systemFontOfSize:16] forKey:@"m_textLabel.font"];
    [row.cellConfig setObject:[UIColor blackColor] forKey:@"m_textLabel.color"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"m_valueLabel.textColor"];
    [section addFormRow:row];
    
    if (_sourceArray.count) {
        section = [XLFormSectionDescriptor formSection];
        [self.form addFormSection:section];
        for (WRNewItem *item in _sourceArray) {
            switch (item.m_columnType) {
                case 1: {   // 文本
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeText title:item.m_name];
                    //                [row.cellConfig setObject:[UIFont systemFontOfSize:14] forKey:@"textField.font"];
                    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                    if (item.m_required) {
                        [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                    }else {
                        [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                    }
                    [section addFormRow:row];
                }
                    break;
                case 2: {   // 文本域
//                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeTextView];
//                    //                [row.cellConfig setObject:[UIFont systemFontOfSize:14] forKey:@"textView.font"];
//                    if (item.m_required) {
//                        [row.cellConfigAtConfigure setObject:item.m_name forKey:@"textView.placeholder"];
//                    }else {
//                        [row.cellConfigAtConfigure setObject:[NSString stringWithFormat:@"%@(必填)", item.m_name] forKey:@"textView.placeholder"];
//                    }
//                    [section addFormRow:row];
                    
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeCustomTextView];
                    [row.cellConfigAtConfigure setObject:item.m_name forKey:@"titleLabel.text"];
                    if (item.m_required) {
                        [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textView.placeholder"];
                    }
                    else {
                        [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textView.placeholder"];
                    }
                    [section addFormRow:row];
                }
                    break;
                case 3: {   // 单选框
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeSelectorPush title:item.m_name];
                    row.selectorTitle = item.m_name;
                    NSMutableArray *selectArray = [NSMutableArray arrayWithCapacity:item.m_selectArray.count];
                    for (NSDictionary *tempDict in item.m_selectArray) {
                        XLFormOptionsObject *optionsObject = [XLFormOptionsObject formOptionsObjectWithValue:tempDict[@"id"] displayText:tempDict[@"value"]];
                        [selectArray addObject:optionsObject];
                    }
                    row.selectorOptions = selectArray;
                    if (item.m_required) {
                        row.noValueDisplayText = @"点击填写";
                    }else {
                        row.noValueDisplayText = @"必填";
                    }
                    [section addFormRow:row];
                }
                    break;
                case 4: {   // 多选框
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeMultipleSelector title:item.m_name];
                    row.selectorTitle = item.m_name;
                    NSMutableArray *selectArray = [NSMutableArray arrayWithCapacity:item.m_selectArray.count];
                    for (NSDictionary *tempDict in item.m_selectArray) {
                        XLFormOptionsObject *optionsObject = [XLFormOptionsObject formOptionsObjectWithValue:tempDict[@"id"] displayText:tempDict[@"value"]];
                        [selectArray addObject:optionsObject];
                    }
                    row.selectorOptions = selectArray;
                    if (item.m_required) {
                        row.noValueDisplayText = @"点击填写";
                    }else {
                        row.noValueDisplayText = @"必填";
                    }
                    [section addFormRow:row];
                }
                    break;
                case 5: {   // 整数
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeInteger title:item.m_name];
                    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                    if (item.m_required) {
                        [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                    }else {
                        [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                    }
                    [section addFormRow:row];
                }
                    break;
                case 6: {   // 浮点数
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeDecimal title:item.m_name];
                    [row.cellConfig setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
                    if (item.m_required) {
                        [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textField.placeholder"];
                    }else {
                        [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textField.placeholder"];
                    }
                    [section addFormRow:row];
                }
                    break;
                case 7: {  // 日期
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeCustomDate title:item.m_name];
                    if (!item.m_fullDate) {
                        [row.cellConfigAtConfigure setObject:@(XLFormCustomDateDatePickerModeDateTime) forKey:@"formDatePickerMode"];
                        row.valueTransformer = [DateTimeValueTrasformer class];
                    }else{
                        [row.cellConfigAtConfigure setObject:@(XLFormCustomDateDatePickerModeDate) forKey:@"formDatePickerMode"];
                    }
                    
                    [row.cellConfig setObject:@(UITableViewCellAccessoryDisclosureIndicator) forKey:@"accessoryType"];
                    
                    if (item.m_required) {
                        row.noValueDisplayText = @"点击填写";
                    }else {
                        row.noValueDisplayText = @"必填";
                        row.value = [NSDate date];
                    }
                    [section addFormRow:row];
                }
                    break;
                    
                    default:
                    break;
            }
        }
    }
    
    // 关联业务
    /*
     初始化审批：
     hasFile          是否需要上传附件
     uploadFile     是否必须上传附件
     
     relevance                     是否有关联业务
     relevanceRequired       关联业务是否必选
     businessCode              关联业务类型
     
     如果有关联业务，关联业务返回类型为空则判定为没有关联业务。
     */
    
//    _hasRelevance = [responseObj[@"hasFile"] integerValue];
//    _relevanceRequired = [responseObj[@"hasFile"] integerValue];
    
    
    ///是否有关联业务
    if (!_hasRelevance && ![_businessCode isEqualToString:@""] && _businessCode.length != 0) {
        section = [XLFormSectionDescriptor formSection];
        [self.form addFormSection:section];
        
        // 关联业务
        row = [XLFormRowDescriptor formRowDescriptorWithTag:kRelevance rowType:XLFormRowDescriptorTypeSelectorTextDetail];
        __weak typeof(self) weak_self = self;
        row.value = @{@"text" : @"关联业务",
                      @"detail" : @"点击选择"};
        row.action.formBlock = ^(XLFormRowDescriptor *sender) {
            RelatedBusinessController *controller = [[RelatedBusinessController alloc] init];
            controller.flagOfRelevance = @"approval";
            controller.businessCode = _businessCode;
            weak_self.RefreshBussineBlock = ^(NSDictionary *fromDic){
                XLFormRowDescriptor *rowDescriptor = [weak_self.form formRowWithTag:kRelevance];
                rowDescriptor.value = @{@"text" : @"关联业务",
                                        @"detail" : [[fromDic objectForKey:@"dataSource"] objectForKey:@"name"],
                                        @"businessType" : [fromDic objectForKey:@"type"],
                                        @"businessId" : [NSString stringWithFormat:@"%@", [[fromDic objectForKey:@"dataSource"] safeObjectForKey:@"id"]]};
                [weak_self updateFormRow:rowDescriptor];
            };
            [self.navigationController pushViewController:controller animated:YES];
        };
        [section addFormRow:row];
        
    }
    
    
    // 审批人
    section = [XLFormSectionDescriptor formSection];
    [self.form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApproval rowType:XLFormRowDescriptorTypeSelectorTextDetail];
    if (_reviewers.count) {
        NSDictionary *reviewerDict = [_reviewers lastObject];
        row.value = @{@"uid" : [NSString stringWithFormat:@"%@", reviewerDict[@"id"]],
                      @"text" : @"审批人",
                      @"detail" : reviewerDict[@"name"]};
    }else {
        row.value = @{@"uid" : @"",
                      @"text" : @"审批人",
                      @"detail" : @""};
    }
    row.action.formBlock = ^(XLFormRowDescriptor *descriptor) {
        if (weakSelf.assignable) {  // 指定审批人
            ApprovalSelectViewController *selecController = [[ApprovalSelectViewController alloc] init];
            selecController.approvalReveiwer = _reviewers;
            selecController.valueBlock = ^(NSDictionary *dict) {
                descriptor.value = @{@"uid" : [NSString stringWithFormat:@"%@", dict[@"id"]],
                                     @"text" : @"审批人",
                                     @"detail" : dict[@"name"]};
                [weakSelf updateFormRow:descriptor];
            };
            [weakSelf.navigationController pushViewController:selecController animated:YES];
        }else {
            
            if (_reviewers && _reviewers.count > 0) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选择指定审批人", @"选择其他审批人", nil];
                actionSheet.tag = 201;
                [actionSheet showInView:weakSelf.view];
            }else{
                
                AddressSelectedController *selectedController = [[AddressSelectedController alloc] init];
                selectedController.title = @"选择审批人";
                selectedController.selectedBlock = ^(AddressBook *item) {
                    XLFormRowDescriptor *descriptor = [self.form formRowWithTag:kApproval];
                    descriptor.value = @{@"uid" : [NSString stringWithFormat:@"%@", item.id],
                                         @"text" : @"审批人",
                                         @"detail" : item.name};
                    [self updateFormRow:descriptor];
                };
                [self.navigationController pushViewController:selectedController animated:YES];
                
                
                
            }
        }

        
        [weakSelf deselectFormRow:descriptor];
    };
    [section addFormRow:row];
    
    // 抄送人
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *tempDict in _ccUsers) {
        AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
        [tempArray addObject:item];
    }
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCopys rowType:XLFormRowDescriptorTypeSelectorPush title:@"抄送人"];
    row.selectorTitle = @"选择抄送人";
    row.noValueDisplayText = @"点击选择";
    if (tempArray.count) {
        row.action.viewControllerClass = [EditAddressViewController class];
    }else {
        row.action.viewControllerClass = [ExportAddressViewController class];
    }
    if (tempArray.count) {
        row.value = [ExportAddress initWithArray:tempArray];
    }
    [section addFormRow:row];
    
    /*
    初始化审批：
    hasFile          是否需要上传附件
    uploadFile     是否必须上传附件
    
    relevance                     是否有关联业务
    relevanceRequired       关联业务是否必选
    businessCode              关联业务类型
    
    如果有关联业务，关联业务返回类型为空则判定为没有关联业务。
     */
    
    
    // 附件是否显示
    if (!_hasFile) {
        
//        section = [XLFormSectionDescriptor formSection];
//        [self.form addFormSection:section];
//        row = [XLFormRowDescriptor formRowDescriptorWithTag:kChoiceFile rowType:XLFormRowDescriptorTypeSelectorTextImage];
//        row.value = @{@"text" : @"添加图片附件",
//                      @"image" : [UIImage imageNamed:@"user_icon_default"],
//                      @"isWebImage" : @(NO)};
//        row.action.formBlock = ^(XLFormRowDescriptor *sender) {
//            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"选择本地图片", nil];
//            actionSheet.tag = 202;
//            [actionSheet showInView:self.view];
//            [self deselectFormRow:sender];
//        };
//        [section addFormRow:row];
        
        section = [XLFormSectionDescriptor formSectionWithTitle:@"附件"];
        [self.form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:kChoiceFile rowType:XLFormRowDescriptorTypeCustomeImage];
        row.action.formBlock = ^(XLFormRowDescriptor *sender) {
            [weakSelf selectImgFile];
        };
        [section addFormRow:row];
    }
}

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
    if ([rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeCustomDate] && [oldValue isEqual:[NSNull null]]) {
        [self updateFormRow:rowDescriptor];
    }
    
    NSIndexPath *indexPath = [self.form indexPathOfFormRow:rowDescriptor];
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[XLFormTextFieldCell class]]) {
        XLFormTextFieldCell *textFieldCell = cell;
        [textFieldCell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    if ([rowDescriptor.tag isEqualToString:kCopys]) {
        if ([rowDescriptor.value formValue]) {
            rowDescriptor.selectorTitle = @"编辑抄送人";
            rowDescriptor.action.viewControllerClass = [EditAddressViewController class];
        }else {
            rowDescriptor.selectorTitle = @"选择抄送人";
            rowDescriptor.action.viewControllerClass = [ExportAddressViewController class];
        }
    }
    
    
    for (WRNewItem *item in _sourceArray) {
        if ([item.m_name isEqualToString:rowDescriptor.tag]) {
            
            switch (item.m_columnType) {
                case 3: {// 单选
                    XLFormOptionsObject *oldOption = oldValue;
                    XLFormOptionsObject *newOption = newValue;
                    if (![newOption isEqual:[NSNull null]]) {
                        item.m_result = [newOption formValue];
                    }
                    else {
                        if (!item.m_required) {
                            rowDescriptor.value = oldOption;
                        }
                        else {
                            item.m_result = nil;
                        }
                    }
                }
            }
        }
    }
    
}





#pragma mark - private method
- (void)assignReveiwer {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选择指定审批人", @"选择其他审批人", nil];
    actionSheet.tag = 201;
    [actionSheet showInView:self.view];
}


///选择附件
-(void)selectImgFile{
    XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:kChoiceFile];
    if(rowDescriptor.value){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"选择本地图片",@"删除", nil];
        actionSheet.tag = 202;
        [actionSheet showInView:self.view];
        [self deselectFormRow:rowDescriptor];
    }else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"选择本地图片", nil];
        actionSheet.tag = 202;
        [actionSheet showInView:self.view];
        [self deselectFormRow:rowDescriptor];
    }
    
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex)
        return;
    
    if (actionSheet.tag == 201) {   // 自选审批人
        
        if (buttonIndex == 0) {
            ApprovalSelectViewController *selecController = [[ApprovalSelectViewController alloc] init];
            selecController.approvalReveiwer = _reviewers;
            selecController.valueBlock = ^(NSDictionary *dict) {
                
                XLFormRowDescriptor *descriptor = [self.form formRowWithTag:kApproval];
                descriptor.value = @{@"uid" : [NSString stringWithFormat:@"%@", dict[@"id"]],
                                     @"text" : @"审批人",
                                     @"detail" : dict[@"name"]};
                [self updateFormRow:descriptor];
            };
            [self.navigationController pushViewController:selecController animated:YES];
        }else {
            
            AddressSelectedController *selectedController = [[AddressSelectedController alloc] init];
            selectedController.title = @"选择审批人";
            selectedController.selectedBlock = ^(AddressBook *item) {
                XLFormRowDescriptor *descriptor = [self.form formRowWithTag:kApproval];
                descriptor.value = @{@"uid" : [NSString stringWithFormat:@"%@", item.id],
                                     @"text" : @"审批人",
                                     @"detail" : item.name};
                [self updateFormRow:descriptor];
            };
            [self.navigationController pushViewController:selectedController animated:YES];
            
//            AddressSelectController *addressSelectController = [[AddressSelectController alloc] init];
//            addressSelectController.title = @"选择审批人";
//            addressSelectController.valueBlock = ^(AddressSelectModel *item) {
//                XLFormRowDescriptor *descriptor = [self.form formRowWithTag:kApproval];
//                descriptor.value = @{@"uid" : [NSString stringWithFormat:@"%d", item.m_id],
//                                     @"text" : @"审批人",
//                                     @"detail" : item.m_name};
//                [self updateFormRow:descriptor];
//            };
//            [self.navigationController pushViewController:addressSelectController animated:YES];
        }
        return;
    }
    
    ///附件
    if (actionSheet.tag == 202) {
        
        switch (buttonIndex) {
            case 0: {   // 拍照
                UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
                pickerController.delegate = self;
                pickerController.allowsEditing = YES;
                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:pickerController animated:YES completion:nil];
            }
                break;
            case 1: {   // 选择本地图片
                 @weakify(self);
                self.assetLibraryController.confirmBtnClickedBlock = ^(NSArray *array) {
                    @strongify(self);
                    [self notifyListView];
                };
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.assetLibraryController];
                [self presentViewController:nav animated:YES completion:nil];
            }
                break;
            case 2: {   // 删除
                XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:kChoiceFile];
                rowDescriptor.value = nil;
                [self updateFormRow:rowDescriptor];
            }
                break;
            default:
                break;
        }
        
    }
    
    
}

/*
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSURL *imageURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset)
    {
        ALAssetRepresentation *representation = [myasset defaultRepresentation];
        _selectImgName = [representation filename];
    };
    
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:imageURL
                   resultBlock:resultblock
                  failureBlock:nil];
    
    XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:kChoiceFile];
    rowDescriptor.value = @{@"text" : @"添加图片附件",
                            @"image" : [info objectForKey:UIImagePickerControllerEditedImage],
                            @"isWebImage" : @(NO)};
    [self updateFormRow:rowDescriptor];
    imgData = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
*/


///刷新列表显示
- (void)notifyListView {
    XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:kChoiceFile];
    for (int i = 0; i < _assetLibraryController.assetManager.selectedArray.count; i ++) {
        PhotoAssetModel *model = _assetLibraryController.assetManager.selectedArray[i];
        PhotoAssetModel *item = model;
        rowDescriptor.value = item;
        [self updateFormRow:rowDescriptor];
    }
}



#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    SEL selectorToCall = @selector(imageWasSavedSuccessfully:didFinishSavingWithError:contextInfo:);
    UIImageWriteToSavedPhotosAlbum(originalImage, self, selectorToCall, NULL);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 保存图片后到相册后，调用的相关方法，查看是否保存成功
- (void) imageWasSavedSuccessfully:(UIImage *)paramImage didFinishSavingWithError:(NSError *)paramError contextInfo:(void *)paramContextInfo{
    if (paramError == nil){
        __weak typeof(self) weak_self = self;
        self.assetLibraryController.confirmBtnClickedBlock = ^(NSArray *array) {
            [weak_self notifyListView];
        };
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.assetLibraryController];
        [self presentViewController:nav animated:YES completion:^{
            // 自动添加拍照图片
            [_assetLibraryController.assetManager.selectedArray removeAllObjects];
            [_assetLibraryController autoAddCameraPhoto];
        }];
        NSLog(@"Image was saved successfully.");
    } else {
        NSLog(@"An error happened while saving the image.");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (PhotoAssetLibraryViewController*)assetLibraryController {
    if (!_assetLibraryController) {
        _assetLibraryController = [[PhotoAssetLibraryViewController alloc] init];
        _assetLibraryController.maxCount = 1;
    }
    return _assetLibraryController;
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
