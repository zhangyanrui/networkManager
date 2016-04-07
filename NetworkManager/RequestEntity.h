//
//  RequestEntity.h
//  LeFilm
//
//  Created by Will Zhang on 15/4/16.
//  Copyright (c) 2015年 LEVP. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NetworkManager.h"
#import <AFNetworking/AFNetworking.h>

@class DataWrapper;

typedef void (^RequestEntityFailedBlock)(RequestEntity *requestEntity, NSError *error);
typedef void (^RequestEntitySuccessBlock)(RequestEntity *requestEntity, DataWrapper *resultDataWrapper);
typedef void (^RequestEntityCancelBlock)(RequestEntity *requestEntity);
typedef void (^RequestEntityFileUploadBlock)(id <AFMultipartFormData> formData);
typedef void(^RequestEntityFileUploadProgressBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);



@interface RequestEntity : NSObject

@property (nonatomic, copy) RequestEntitySuccessBlock successBlock;//成功回调块
@property (nonatomic, copy) RequestEntityFailedBlock failedBlock;//失败回调块
@property (nonatomic, copy) RequestEntityCancelBlock cancelBlock;//取消回调块
@property (nonatomic, copy) RequestEntityFileUploadBlock fileUploadBlock;//上传文件的block  文件信息放在这里面
@property (nonatomic, copy) RequestEntityFileUploadProgressBlock uploadProgressBlock;//上传文件进度的block
@property (nonatomic, strong) NSString *urlString;//Url
@property (nonatomic, strong) NSDictionary *pargramDic;//参数字典
@property (nonatomic, assign) RequestMethodType requestMthod;//get或者post
@property (nonatomic, assign) RequestStatus requestStatus;
@property (nonatomic, assign) NSInteger statusCode;//
@property (nonatomic, strong) NSString *messageString;
@property (nonatomic, assign) BOOL shouldAuth;
@property (nonatomic, assign) BOOL isMyApplication;
@property (nonatomic, assign) BOOL showWErrorMessage;//是否显示服务器返回的erroMessage，默认NO  配合HudLoading使用

///本实体所在的请求队列
@property (nonatomic, weak)AFHTTPRequestOperation *currentRequestOperation;

///开始请求 这个方法在本类对象配置完成之后调用 请求网络
- (void)startConnect;

///取消正在请求的 aEntity请求
+ (void)cancelEntityIfThatIsLoading:(RequestEntity *)aEntity;

+ (RequestEntity *)entityWithUrlString:(NSString *)urlStr methodType:(RequestMethodType)methodType successBlock:(RequestEntitySuccessBlock)successBlock failedBlock:(RequestEntityFailedBlock)failedBlock;

+ (RequestEntity *)entityWithUrlString:(NSString *)urlStr methodType:(RequestMethodType)methodType successBlock:(RequestEntitySuccessBlock)successBlock failedBlock:(RequestEntityFailedBlock)failedBlock cancelBlock:(RequestEntityCancelBlock)cancelBlock;

+ (RequestEntity *)entityWithUrlString:(NSString *)urlStr methodType:(RequestMethodType)methodType fileUploadBlock:(RequestEntityFileUploadBlock)fileUploadBlock uploadProgressBlock:(RequestEntityFileUploadProgressBlock)uploadProgressBlock successBlock:(RequestEntitySuccessBlock)successBlock failedBlock:(RequestEntityFailedBlock)failedBlock;

/////////////////////////////////////////////////////////////////////////////
@end
