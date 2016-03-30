 //
//  ApprovalEditViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/8/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "ApprovalEditViewController.h"
#import "AFNHttp.h"
#import "WRNewItem.h"
#import <XLForm.h>
#import <MBProgressHUD.h>
#import "SBJson.h"
#import "XLFTextValueCell.h"
#import "XLFSelectorTextImageCell.h"
#import "ApprovalEditInputViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "CommonFuntion.h"
#import "AddressSelectedController.h"
#import "ExportAddress.h"
#import "EditAddressViewController.h"
#import "ExportAddressViewController.h"
#import "XLFormCustomTextViewCell.h"
#import "XLFormCustomImageCell.h"
#import "XLFormCustomDateCell.h"
#import "DateAndTimeValueTrasformer.h"
#import "PhotoAssetLibraryViewController.h"
#import "PhotoAssetModel.h"

static NSString *const kApproval = @"approval";
static NSString *const kCopys = @"copys";
static NSString *const kChoiceFile = @"choiceFile";        // 选择图片附件

@interface ApprovalEditViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) PhotoAssetLibraryViewController *assetLibraryController;
@property (nonatomic, assign) NSInteger uploadFile;
@end

@implementation ApprovalEditViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = kView_BG_Color;
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemPress)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"编辑审批 = %@", _sourceDict);
    
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeTextValue];
    row.value = @{@"text" : _flowName,
                  @"value" : [NSString stringWithFormat:@"申请人：%@", _sourceDict[@"examine"][@"applyUser"][@"name"]],
                  @"isEdit" : @0};
    [row.cellConfig setObject:[UIFont systemFontOfSize:16] forKey:@"m_textLabel.font"];
    [row.cellConfig setObject:[UIColor blackColor] forKey:@"m_textLabel.color"];
    [row.cellConfig setObject:[UIColor lightGrayColor] forKey:@"m_valueLabel.textColor"];
    [section addFormRow:row];
    
    if ([[[_sourceDict objectForKey:@"examine"] objectForKey:@"columnList"] count]) {
        section = [XLFormSectionDescriptor formSection];
        [form addFormSection:section];
        
        for (NSDictionary *tempDict in [[_sourceDict objectForKey:@"examine"] objectForKey:@"columnList"]) {
            WRNewItem *item = [WRNewItem initWithDictionary:tempDict];
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
                    row.value = item.m_result;
                    [section addFormRow:row];
                }
                    break;
                case 2: {   // 文本域
//                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeSelectorPush title:item.m_name];
//                    row.action.viewControllerClass = [ApprovalEditInputViewController class];
//                    row.value = item.m_result;
//                    [section addFormRow:row];
                    
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeCustomTextView];
                    [row.cellConfigAtConfigure setObject:item.m_name forKey:@"titleLabel.text"];
                    if (item.m_required) {
                        [row.cellConfigAtConfigure setObject:@"点击填写" forKey:@"textView.placeholder"];
                    }
                    else {
                        [row.cellConfigAtConfigure setObject:@"必填" forKey:@"textView.placeholder"];
                    }
                    row.value = item.m_result;
                    [section addFormRow:row];
                }
                    break;
                case 3: {   // 单选框
                    row = [XLFormRowDescriptor formRowDescriptorWithTag:item.m_name rowType:XLFormRowDescriptorTypeSelectorPush title:item.m_name];
                    row.selectorTitle = item.m_name;
                    NSMutableArray *selectArray = [NSMutableArray arrayWithCapacity:item.m_selectArray.count];
                    for (NSDictionary *tempDict in item.m_selectArray) {
                        XLFormOptionsObject *optionsObject = [XLFormOptionsObject formOptionsObjectWithValue:@([[tempDict objectForKey:@"id"] integerValue]) displayText:tempDict[@"value"]];
                        [selectArray addObject:optionsObject];
                        
                        if ([[tempDict objectForKey:@"id"] integerValue] == [item.m_result integerValue]) {
                            row.value = [XLFormOptionsObject formOptionsObjectWithValue:@([item.m_result integerValue]) displayText:[tempDict objectForKey:@"value"]];
                        }
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
                        XLFormOptionsObject *optionsObject = [XLFormOptionsObject formOptionsObjectWithValue:@([tempDict[@"id"] integerValue]) displayText:tempDict[@"value"]];
                        [selectArray addObject:optionsObject];
                        
                    }
                    
                    NSMutableArray *valueArray = [[NSMutableArray alloc] initWithCapacity:0];
                    NSArray *resultArray = [item.m_result componentsSeparatedByString:@","];
                    for (NSString *tempStr in resultArray) {
                        for (NSDictionary *tempDict in item.m_selectArray) {
                            if ([[tempDict objectForKey:@"id"] integerValue] == [tempStr integerValue]) {
                                [valueArray addObject:[XLFormOptionsObject formOptionsObjectWithValue:@([tempStr integerValue]) displayText:[tempDict objectForKey:@"value"]]];
                            }
                        }
                    }
                    
                    if (valueArray.count) {
                        row.value = valueArray;
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
                    row.value = item.m_result;
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
                    row.value = item.m_result;
                    [section addFormRow:row];
                }
                    break;
                default: {  // 日期
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
                    }
                    else {
                        row.noValueDisplayText = @"必填";
                    }
                    if ([CommonFuntion checkNullForValue:item.m_result]) {
                        
                        NSNumber *timeSince1970 = (NSNumber *)item.m_result;
                        NSTimeInterval timeSince1970TimeInterval = timeSince1970.doubleValue/1000;
                        row.value = [NSDate dateWithTimeIntervalSince1970:timeSince1970TimeInterval];
                        
//                        if (!item.m_fullDate) {
//                            row.value = [CommonFuntion stringToDate:[CommonFuntion transDateWithTimeInterval:[item.m_result longLongValue] withFormat:@"yyyy-MM-dd HH:mm"] Format:@"yyyy-MM-dd HH:mm"];
//                        }else{
//                            row.value = [CommonFuntion stringToDate:[CommonFuntion transDateWithTimeInterval:[item.m_result longLongValue] withFormat:@"yyyy-MM-dd"] Format:@"yyyy-MM-dd"];
//                        }

                    }
                    [section addFormRow:row];
                }
                    break;
            }
        }
    }
    
    if ([CommonFuntion checkNullForValue:[_sourceDict objectForKey:@"from"]]) {
        section = [XLFormSectionDescriptor formSectionWithTitle:@"关联业务"];
        [form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"business" rowType:XLFormRowDescriptorTypeTextValue];
        row.value = @{@"text" : [[_sourceDict objectForKey:@"from"] safeObjectForKey:@"sourceName"],
                      @"value" : [[_sourceDict objectForKey:@"from"] safeObjectForKey:@"name"],
                      @"isEdit" : @0,
                      @"businessId" : [[_sourceDict objectForKey:@"from"] safeObjectForKey:@"id"],
                      @"businessType" : [[_sourceDict objectForKey:@"from"] safeObjectForKey:@"sourceId"]};
        row.action.formBlock = ^(XLFormRowDescriptor *rowDescriptor) {

        };
        [section addFormRow:row];
    }

    // 审批人、抄送人
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kApproval rowType:XLFormRowDescriptorTypeSelectorPush title:@"审批人"];
    row.selectorTitle = @"选择审批人";
    row.noValueDisplayText = @"点击选择";
    row.action.viewControllerClass = [AddressSelectedController class];
    if ([CommonFuntion checkNullForValue:_sourceDict[@"reveiwers"]] && [_sourceDict[@"reveiwers"] count] > 0) {
        row.value = [NSObject objectOfClass:@"AddressBook" fromJSON:_sourceDict[@"reveiwers"][0]];
    } else {
        row.noValueDisplayText = @"点击选择";
    }
//    row.disabled = @1;
    [section addFormRow:row];
    
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *tempDict in _sourceDict[@"examine"][@"ccUsers"]) {
        AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
        [tempArray addObject:item];
    }
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kCopys rowType:XLFormRowDescriptorTypeSelectorPush title:@"抄送人"];
    row.noValueDisplayText = @"点击选择";
    if (tempArray.count) {
        row.selectorTitle = @"编辑抄送人";
        row.action.viewControllerClass = [EditAddressViewController class];
    }else {
        row.selectorTitle = @"选择抄送人";
        row.action.viewControllerClass = [ExportAddressViewController class];
    }
    if (tempArray.count) {
        row.value = [ExportAddress initWithArray:tempArray];
    }
    [section addFormRow:row];
    
    
    NSInteger hasFile = [_sourceDict[@"hasFile"] integerValue];
    ///是否显示附件选项
    if (!hasFile) {
        __weak typeof(self) weak_self = self;
        section = [XLFormSectionDescriptor formSectionWithTitle:@"附件"];
        [form addFormSection:section];
        
        row = [XLFormRowDescriptor formRowDescriptorWithTag:kChoiceFile rowType:XLFormRowDescriptorTypeCustomeImage];
        if ([CommonFuntion checkNullForValue:[_sourceDict objectForKey:@"file"]]) {
            NSString *imgUrl = [[_sourceDict objectForKey:@"file"] safeObjectForKey:@"url"];
            row.value = imgUrl;
        }
        
        row.action.formBlock = ^(XLFormRowDescriptor *sender) {
            [weak_self selectImgFile];
        };
        [section addFormRow:row];
    }
    
    self.form = form;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 限制textField字数
- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length > MAX_LIMIT_TEXTFIELD) {
        textField.text = [textField.text substringToIndex:MAX_LIMIT_TEXTFIELD];
    }
}

#pragma mark - event response
- (void)rightButtonItemPress {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    XLFormRowDescriptor *row;
    
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@([_sourceDict[@"examine"][@"id"] integerValue]) forKey:@"id"];
    [params setObject:@([_sourceDict[@"examine"][@"customId"] integerValue]) forKey:@"customId"];
    
    row = [self.form formRowWithTag:kApproval];
    if ([row.value formValue]) {
        [params setObject:[row.value formValue] forKey:@"reviewerId"];
    }
    
    row = [self.form formRowWithTag:kCopys];
    if ([row.value formValue]) {
        [params setObject:[row.value formValue] forKey:@"ccUserIds"];
    }
    
    NSMutableArray *jsonArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSDictionary *tempDict in _sourceDict[@"examine"][@"columnList"]) {
        WRNewItem *item = [WRNewItem initWithDictionary:tempDict];
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
    row = [self.form formRowWithTag:@"business"];
    NSLog(@"row.value:%@",row.value);
    if (row.value && [row.value objectForKey:@"businessId"] && [[row.value objectForKey:@"businessId"] length] > 0 ) {
        if ([[row.value allKeys] containsObject:@"businessType"]) {
            [params setObject:[row.value objectForKey:@"businessType"] forKey:@"businessType"]; //业务类型
        }
        if ([[row.value allKeys] containsObject:@"businessId"]) {
            [params setObject:[row.value objectForKey:@"businessId"] forKey:@"businessId"]; //业务id
        }
    }
    
    NSInteger hasFile = [_sourceDict[@"hasFile"] integerValue];
    NSInteger uploadFile = [_sourceDict[@"uploadFile"] integerValue];
    
    row = [self.form formRowWithTag:kChoiceFile];
    ///显示了附件
    if (!hasFile) {
        ///图片附件为必填时 不能为空
        if (!uploadFile && !row.value) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"请选择图片附件" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
            return;
        }
    }
    
    ///非必填情况下删除了图片
    if (!row.value) {
        [params setObject:@"1" forKey:@"deleteFile"];
    }
    
    MySBJsonWriter *jsonParser = [[MySBJsonWriter alloc]init];
    NSString *jsonString =[jsonParser stringWithObject:jsonArray];
    [params setObject:jsonString forKey:@"json"];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    [hud show:YES];
    
    __weak __block typeof(self) weak_self = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript",@"text/plain", nil];
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager POST:[NSString stringWithFormat:@"%@%@",MOBILE_SERVER_IP_OA,kNetPath_Approve_Submit] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (row.value) {
            
            ///图片未修改
            if ([row.value isKindOfClass:[NSString class]]){
                
            }else{
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
        }
    } success:^(AFHTTPRequestOperation *operation,id responseObject) {
        [hud hide:YES];
        NSLog(@"responseObj:%@",responseObject);
        NSLog(@"desc:%@",[responseObject objectForKey:@"desc"]);
        if (responseObject && [[responseObject objectForKey:@"status"] integerValue] == 0) {
            NSLog(@"修改审批成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ApprovalRefreshGroupList" object:nil];
            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
        }else{
            NSString *desc = @"";
            desc = [responseObject objectForKey:@"desc"];
            if ([desc isEqualToString:@""]) {
                desc = @"提交失败";
            }
            kShowHUD(desc,nil)
        }
        
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        NSLog(@"error:%@",error);
        [hud hide:YES];
        kShowHUD(NET_ERROR)
        NSLog ( @"operation: %@" , operation. responseString );
        NSLog(@"error:%@",error);
    }];

}

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue {
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];
    
    NSIndexPath *indexPath = [self.form indexPathOfFormRow:rowDescriptor];
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[XLFormTextFieldCell class]]) {
        XLFormTextFieldCell *textFieldCell = cell;
        [textFieldCell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    if ([rowDescriptor.rowType isEqualToString:XLFormRowDescriptorTypeCustomDate] && [oldValue isEqual:[NSNull null]]) {
        [self updateFormRow:rowDescriptor];
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
}



///选择附件
-(void)selectImgFile{
    XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:kChoiceFile];
    NSInteger uploadFile = [_sourceDict[@"uploadFile"] integerValue];
    ///必填
    if (!uploadFile) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"选择本地图片", nil];
        actionSheet.tag = 202;
        [actionSheet showInView:self.view];
        [self deselectFormRow:rowDescriptor];
    }else{
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
}


///刷新UI显示
- (void)notifyListView {
    XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:kChoiceFile];
    for (int i = 0; i < _assetLibraryController.assetManager.selectedArray.count; i ++) {
        PhotoAssetModel *model = _assetLibraryController.assetManager.selectedArray[i];
        PhotoAssetModel *item = model;
        rowDescriptor.value = item;
        [self updateFormRow:rowDescriptor];
    }
}


#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex)
        return;
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
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex)
        return;
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    
    switch (buttonIndex) {
        case 0: {   // 拍照
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
            break;
        case 1: {   // 选择本地图片
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
            break;
        default:
            break;
    }
    [self presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    XLFormRowDescriptor *rowDescriptor = [self.form formRowWithTag:kChoiceFile];
    rowDescriptor.value = @{@"text" : @"添加图片附件",
                            @"image" : [info objectForKey:UIImagePickerControllerEditedImage],
                            @"isWebImage" : @(NO)};
    [self updateFormRow:rowDescriptor];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
*/




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
