//
//  Net_APIManager.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "Net_APIManager.h"
#import "Login.h"
#import "Record.h"
#import "PhotoAssetModel.h"

@implementation Net_APIManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static Net_APIManager *apiManager = nil;
    dispatch_once(&onceToken, ^{
        apiManager = [[Net_APIManager alloc] init];
    });
    return apiManager;
}

- (void)request_Login_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Web_Server_Base, kNetPath_Login] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            if ([data objectForKey:@"tenants"] && [[data objectForKey:@"tenants"] count]) {
                block(data, nil);
            }else {
                [Login doLogin:data];
                User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:data];
                block(curLoginUser, nil);
            }
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Logout_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    
}

- (void)request_ChooseCompany_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Web_Server_Base, kNetPath_ChooseCompany] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            [Login doLogin:data];
            User *curLoginUser = [NSObject objectOfClass:@"User" fromJSON:data];
            block(curLoginUser, nil);
        }else {
            block(nil, error);
        }
    }];
}

#pragma mark - 注册
- (void)request_SendCaptcha_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Web_Server_Base, kNetPath_SendCaptcha] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_CheckAccountName_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Web_Server_Base, kNetPath_CheckAccountName] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_CheckAccountPassword_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Web_Server_Base, kNetPath_CheckAccountPassword] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

#pragma mark - 修改密码
- (void)request_UpdatePassword_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_updatePassword] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

#pragma mark - 找回密码
- (void)request_FindPassword_ResetPassword_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_User_Server_Base, kNetPath_ResetPassword] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_FindPassword_VerificationCode_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_User_Server_Base, kNetPath_VerificationCode] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_FindPassword_SetNewPassword_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_User_Server_Base, kNetPath_SetNewPassword] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

#pragma mark - Common_CRM筛选
- (void)request_CRM_Common_Filter_WithPath:(NSString *)aPath block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, aPath] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_CRM_Common_Index_WithPath:(NSString *)aPath block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, aPath] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

#pragma mark - Common——CRM详情
- (void)request_Common_CRMDetail_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_CRMFollowRecord_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_SendRecord_WithPath:(NSString *)path obj:(Record *)record block:(void (^)(id, NSError *))block {
    [NSObject showStatusBarQueryStr:@"正在快速记录"];
    [[AFNOManagerPost sharedJsonClient] POST:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] parameters:[record toDoRecordParams] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for (PhotoAssetModel *tempItem in record.recordImages) {
            UIImage *tempImage = [UIImage imageWithCGImage:[[tempItem.asset defaultRepresentation] fullScreenImage]];
            NSData *data = UIImageJPEGRepresentation(tempImage, 1.0);
            if ((float)data.length/1024 > 1000) {
                data = UIImageJPEGRepresentation(tempImage, 1024*1000.0/(float)data.length);
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
            
            [formData appendPartWithFileData:data name:@"pictures" fileName:fileName mimeType:@"image/jpeg"];
        }
        
        if (record.simpleImage) {
            NSData *data = UIImageJPEGRepresentation(record.simpleImage, 1.0);
            if ((float)data.length/1024 > 1000) {
                data = UIImageJPEGRepresentation(record.simpleImage, 1024*1000.0/(float)data.length);
            }
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
            
            [formData appendPartWithFileData:data name:@"pictures" fileName:fileName mimeType:@"image/jpeg"];
        }
        
        if (record.recordAudioFile && [[NSFileManager defaultManager] fileExistsAtPath:record.recordAudioFile]) {
            NSData *audioData = [NSData dataWithContentsOfFile:record.recordAudioFile];
            NSString *audioFileName = [record.recordAudioFile lastPathComponent];
            
            //            [formData appendPartWithFileData:audioData name:@"audio" fileName:audioFileName mimeType:@"audio/amr"];
            [formData appendPartWithFileData:audioData name:@"audio" fileName:audioFileName mimeType:@"application/octet-stream"];
            
            // 删除录音文件
            [[NSFileManager defaultManager] removeItemAtPath:record.recordAudioFile error:nil];
        }
        
    } success:^(AFHTTPRequestOperation *operation,id responseObject) {
        
        NSError *error = nil;
        // status为1时，表示有错
        NSNumber *resultCode = [responseObject valueForKeyPath:@"status"];
        if (resultCode.intValue) {
            error = [NSError errorWithDomain:kNetPath_Web_Server_Base code:resultCode.intValue userInfo:responseObject];
        }
        if (error) {
            [NSObject showStatusBarErrorStr:@"发送失败"];
            block(nil, error);
        }else {
            [NSObject showStatusBarSuccessStr:@"快速记录成功"];
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        [NSObject showStatusBarErrorStr:@"发送失败"];
        DebugLog(@"\n==========response==========:\n%@", error);
    }];
}

- (void)request_Common_FocusOrCancel_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_Transfer_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_Trash_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_Delete_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}




#pragma mark - Common
- (void)request_Common_Init_WithPath:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_FollowRecord_List_WithPath:(NSString *)path Params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_AddStaffs_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_UpdateAccess_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_DeleteStaff_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_OpportunityList_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_OpportunityInit_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_OpportunitySave_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_ContactList_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_ContactInit_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_ContactSave_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_Customer_List_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_TaskSchedule_List_WithPath:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_Approval_List_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_ProductList_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_File_List_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_File_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_DeleteActivity_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Common_DeleteActivity] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_CommentList_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Common_CommentList] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_AddComment_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Common_AddComment] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_DeleteComment_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Common_DeleteComment] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_ChangeState_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_SaleLeadsList_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_CreateTaskSchedule_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_ChangeCustomerStatus_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Common_ChangeCustomerStatus] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_BackReason_WithPath:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_BackToPool_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_ScanningCard_WithPath:(NSString *)path image:(UIImage *)image params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] uploadImage:image path:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] params:params name:@"card" successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(responseObject, nil);
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(nil, error);
    } progressBlock:^(CGFloat progressValue) {
        
    }];
}

- (void)request_Common_EditOrSave_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Common_SearchList_WithParams:(id)params path:(NSString *)path block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}


- (void)request_Activity_Init_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_Init] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_Menu_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_Select_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_Filter_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_Filter] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_Create_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_Create] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_Detail_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_Detail] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_EditOrSave_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_EditOrSave] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_FocusOrCancel_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_FocusOrCancel] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_Transfer_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_Transfer] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_Delete_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_Delete] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Activity_UpdateAttendedStatus_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Activity_UpdateAttendedStatus] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Pool_GroupList_WithType:(NSInteger)type block:(void (^)(id, NSError *))block {
    NSArray *array = @[kNetPath_LeadPool_List, kNetPath_CustomerPool_List];
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, array[type]] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Pool_DetailList_WithType:(NSInteger)type params:(id)params block:(void (^)(id, NSError *))block {
    NSArray *array = @[kNetPath_LeadPool_Detail, kNetPath_CustomerPool_Detail];
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, array[type]] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Pool_Get_WithType:(NSInteger)type params:(id)params block:(void (^)(id, NSError *))block {
    NSArray *array = @[kNetPath_LeadPool_Get, kNetPath_CustomerPool_Get];
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, array[type]] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_Init_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_Init] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_New_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_New] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_Menu_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_Select_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_Filter_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_Filter] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_Detail_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_Detail] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_EditOrSave_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_EditOrSave] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_Transfer_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_Transfer] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_Delete_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_Delete] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_Search_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_Search] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_ChangeToCustomerInit_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_ChangeToCustomerInit] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_ChangeToCustomer_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_ChangeToCustomer] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Lead_Trash_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Lead_Trash] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}




#pragma mark - 客户
- (void)request_Customer_Init_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_Init] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}
- (void)request_Customer_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_New_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_New] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_Filter_WithBlock:(void (^)(id, NSError *))block {
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    //    [params setObject:@(type) forKey:@"type"];
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_Filter] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_EditOrSave_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_EditOrSave] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_Menu_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_Select_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

//- (void)request_Customer_Type_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
//    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Mobile_Server_Base, kNetPath_Customer_Type] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
//        if (data) {
//            block(data, nil);
//        }else {
//            block(nil, error);
//        }
//    }];
//}

- (void)request_Customer_FocusOrCancelWithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_FocusOrCancel] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_Detail_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_Detail] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_Transfer_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_Transfer] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_AddCustomerFromActivity_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_AddCustomerFromActivity] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_Search_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_Search] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_Delete_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_Delete] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_NewOpportunity_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_NewOpportunity] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Customer_SaveNewOpportunity_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Customer_SaveNewOpportunity] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}


#pragma mark - 联系人
- (void)request_Contact_Init_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Contact_Init] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Contact_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_Menu_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Contact_Select_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_Filter_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Contact_Filter] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_NewInit_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_ValidateCustomer_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Contact_ValidateCustomer] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_EditOrSave_WithPath:(NSString *)path params:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, path] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_Detail_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Contact_Detail] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_Transfer_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Contact_Transfer] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_Delete_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Contact_Delete] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Contact_ListFromCustomer_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Contact_ListFromCustomer] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}


#pragma mark - 销售机会
- (void)request_SaleChance_StageList_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_StageList] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_IndexList_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_Select_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_Filter_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_Filter] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_Type_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_Type] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_NewInit_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_NewInit] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_EditOrSave_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_EditOrSave] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_FocusOrCancel_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_FocusOrCancel] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_Detail_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_Detail] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_Transfer_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_Transfer] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_Delete_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_Delete] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_ChangeStage_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_ChangeStage] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_ListFromCustomer_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_ListFromCustomer] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_ContactListFromOpportunity_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_ContactListFromOpportunity] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_AddContact_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_AddContact] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_AssignMainContact_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_AssignMainContact] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}

- (void)request_SaleChance_LostReasons_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_SaleChance_LoseReasons] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }
        else {
            block(nil, error);
        }
    }];
}


#pragma mark - 活动记录
- (void)request_ActivityRecord_Types_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_ActivityRecord_Types] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_ActivityRecord_List_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_ActivityRecord_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_ActivityRecord_Type_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_ActivityRecord_Type] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}



#pragma mark - 产品
- (void)request_Product_List_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Product_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Product_Detail_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Crm_Server_Base, kNetPath_Product_Detail] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}


#pragma mark - 动态
- (void)request_Dynamic_Delete_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Dynamic_Delete] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Dynamic_Like_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Dynamic_Like] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Dynamic_AddOrDeleteFavorite_WithParams:(id)params isFavorite:(BOOL)isFavorite block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, isFavorite ? kNetPath_Dynamic_AddFavorite : kNetPath_Dynamic_DeleteFavorite] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

#pragma mark - 通讯录
- (void)request_Address_List_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Address_List] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_DepartmentOrGroup_List_WithParams:(id)params listType:(NSInteger)type andBlock:(void (^)(id, NSError *))block {
    NSArray *pathArray = @[kNetPath_Address_Department_List, kNetPath_Address_Group_List];
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, pathArray[type]] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Address_Member_List_WithParams:(id)params memberType:(NSInteger)type andBlock:(void (^)(id, NSError *))block {
    NSArray *pathArray = @[kNetPath_Address_DepartmentChild_StaffsList, kNetPath_Address_GroupChild_StaffList];
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, pathArray[type]] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Address_DynamicList_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Address_DynamicList] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}


#pragma mark - 工作报告
- (void)request_Report_List_WithParams:(id)params type:(NSInteger)type andBlock:(void (^)(id, NSError *))block {
    NSArray *pathArray = @[kNetPath_Report_Mine, kNetPath_Report_ToMe, kNetPath_Report_All];
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, pathArray[type]] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Report_Filter_WithType:(NSInteger)type andBlock:(void (^)(id, NSError *))block {
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:COMMON_PARAMS];
    [params setObject:@(type) forKey:@"type"];
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Report_Filter] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Report_Create_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Report_Create] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Report_WorkResult_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Report_WorkResult] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Approve_List_WithParams:(id)params andTypeIndex:(NSInteger)typeIndex andBlock:(void (^)(id, NSError *))block {
    NSArray *pathArray = @[kNetPath_Approve_Mine, kNetPath_Approve_ToMe, kNetPath_Approve_All];
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, pathArray[typeIndex]] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Approve_Type_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Approve_Type] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Approve_Flow_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Approve_Flow] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Approve_New_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Approve_Application] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Approve_Detail_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Approve_Detail] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Approve_Submit_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Approve_Submit] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Approve_Reback_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Approve_Reback] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        
        block(data, nil);
    }];
}

- (void)request_Approve_Delete_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Approve_Delete] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        block(data, nil);
    }];
}

- (void)request_Approve_Agree_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Approve_Agree] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        block(data, nil);
    }];
}

- (void)request_Approve_Refuse_WithParams:(id)params andBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Approve_Refuse] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        block(data, nil);
    }];
}

#pragma mark - 日程
- (void)request_Schedule_Detail_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Schedule_Detail] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Schedule_Type_WithBlock:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Schedule_Type] withParams:COMMON_PARAMS withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Schedule_Delete_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Schedule_Delete] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

#pragma mark - 任务
- (void)request_Task_Detail_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Task_Detail] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}

- (void)request_Task_Delete_WithParams:(id)params block:(void (^)(id, NSError *))block {
    [[AFNOManagerPost sharedJsonClient] requestJsonDataWithPath:[NSString stringWithFormat:@"%@%@", kNetPath_Oa_Server_Base, kNetPath_Task_Delete] withParams:params withMethodType:Post andBlock:^(id data, NSError *error) {
        if (data) {
            block(data, nil);
        }else {
            block(nil, error);
        }
    }];
}



@end
