
//
//  NetworkManager.m
//  LeFilm
//
//  Created by Will Zhang on 15/4/16.
//  Copyright (c) 2015年 LEVP. All rights reserved.
//


#import "NetworkManager.h"
#import <AFNetworking.h>
#import "RequestEntity.h"
#import "UserManager.h"
#import "DataWrapper.h"
#import "LeyingUserAgentManager.h"
#import "UserManager.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import "LogTool.h"


@interface RequestEntity ()

@property (nonatomic, assign)CGFloat uploadPercent;


@end

@interface AFURLConnectionOperation ()
@property (readwrite, nonatomic, strong) NSURLRequest *request;
@end




#define KEY_OAUTH_ACCESS_TOKEN @"OAuthAccessToken"


@interface NetworkManager()

//这个可变数组用来维护请求队列
@property (nonatomic, strong)NSMutableArray *connectQueueArray;
@property (nonatomic, strong) AFNetworkReachabilityManager *afNetManager;

@end

@implementation NetworkManager
@synthesize accessToken=_accessToken;

#pragma mark - LifeCycle

static NetworkManager *sharedManager = nil;

+(NetworkManager *)sharedManager
{
    static dispatch_once_t doneTime;
	
    dispatch_once(&doneTime, ^{
        sharedManager = [[NetworkManager alloc] init];
    });
    
	return sharedManager;
}

#pragma mark - Data

- (NSMutableArray *)connectQueueArray
{
    if (_connectQueueArray) {
        return _connectQueueArray;
    }
    _connectQueueArray = [[NSMutableArray alloc]init];
    return _connectQueueArray;
}

- (void)setAccessToken:(NSString *)accessToken
{
    if (accessToken && [accessToken isEqualToString:_accessToken]) {
        return;
    }
    _accessToken = accessToken;
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:KEY_OAUTH_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)accessToken
{
    if (_accessToken) {
        return _accessToken;
    }
    _accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_OAUTH_ACCESS_TOKEN];
    return _accessToken;
}


#pragma mark - Tools
/**
 *  记录请求时长
 *
 *  @param url       shortUrl
 *  @param startTime 开始请求时间
 */
- (void)logRequestTimeIntervalWithUrl:(NSString *)url startTime:(NSDate *)startTime{
    
    NSDate *currentDate = [NSDate date];

    NSTimeInterval requestDuration = [currentDate timeIntervalSinceDate:startTime];
    NSString *logStr = [NSString stringWithFormat:@"时间:%@\n链接:%@\n请求时长:%f", [self hmseTimeStringFromDate:currentDate], url, requestDuration];
//    LogTool
//    [[LogTool defaultManager] writeLogString:logStr];
}

/**
 *  记录页面渲染时长
 *
 *  @param url       shortUrl
 *  @param startTime 开始渲染时间
 */
- (void)logLocalTimeIntervalWithUrl:(NSString *)url startTime:(NSDate *)startTime{
    
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval duration = [currentDate timeIntervalSinceDate:startTime];
    NSString *logStr = [NSString stringWithFormat:@"时间:%@\n链接:%@\n渲染时长:%f ",[self hmseTimeStringFromDate:currentDate], url, duration];
//    [[LogTool defaultManager] writeLogString:logStr];
}

///返回时分秒string
- (NSString *)hmseTimeStringFromDate:(NSDate *)date{
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    [fmt setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [fmt setDateFormat:@"HH:mm:ss"];
    return [fmt stringFromDate:date];
    
}


#pragma mark - Base Method

- (void)httpRequestWithUrl:(NSString *)urlStr method:(RequestMethodType)methodType authorizationHeader:(NSString *)authorizationHeaderStr prames:(NSDictionary *)params entity:(RequestEntity *)requestEn{
    
    __block NSDate *requestStartTime = nil;
    
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
 
    [requestSerializer setValue:[[LeyingUserAgentManager defaultManager] getUserAgentString] forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setTimeoutInterval:RequestTimeOutSeconds];
    

    if (authorizationHeaderStr && authorizationHeaderStr.length) {
        [requestSerializer setValue:authorizationHeaderStr forHTTPHeaderField:@"Authorization"];
    }

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    if (requestEn.isMyApplication) {
        manager.requestSerializer = requestSerializer;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    }else{
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    }
    
    
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self logRequestTimeIntervalWithUrl:requestEn.urlString startTime:requestStartTime];
        
        
        NSDictionary *deserializedData = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingAllowFragments error:nil];
        if (deserializedData) {
            
            NSInteger statusCode = operation.response.statusCode;
            if ( (statusCode >= 200 && statusCode <= 206) || (statusCode >= 300 && statusCode <= 307) ) {
                DataWrapper *responseDataWrapper = [DataWrapper dataWrapperWithObject:deserializedData];
                //[responseDataWrapper printObject];
                requestEn.statusCode = statusCode;
                requestEn.messageString = [responseDataWrapper stringForKey:@"message"];
                requestEn.requestStatus = RequestStatusSuccess;
                
                NSDate *localStartTime = [NSDate date];
                requestEn.successBlock(requestEn, responseDataWrapper);
                [self logLocalTimeIntervalWithUrl:requestEn.urlString startTime:localStartTime];
                
                return;
            }
            
           
            DataWrapper *responseDataWrapper = [DataWrapper dataWrapperWithObject:deserializedData];
            NSString *errorMessage = [responseDataWrapper stringForKey:@"message"];
            
            if (!errorMessage) {
                errorMessage = @"未知错误";
            }
            NSError *aError = [NSError errorWithDomain:errorMessage code:statusCode userInfo:deserializedData];
            requestEn.statusCode = statusCode;
            requestEn.messageString = errorMessage;
            requestEn.requestStatus = RequestStatusFailed;
            requestEn.failedBlock(requestEn, aError);
            return;
            
        }else{
            requestEn.statusCode = operation.response.statusCode;
            requestEn.messageString = @"未知错误";
            requestEn.requestStatus = RequestStatusFailed;
            requestEn.failedBlock(requestEn, [NSError errorWithDomain:@"未知错误" code:0 userInfo:nil]);
        }
        
    };
    void (^failedBlock)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        
        CLog(@"-------------网络连接失败-------------\n %@", error);
        NSDictionary *deserializedData = operation.responseObject;
        NSInteger statusCode = operation.response.statusCode;
        NSString *errorMessage = @"无网络连接";
        if (statusCode == 0) {
            
            errorMessage = @"无网络连接";
            
        }else if (statusCode == 500) {
            
            errorMessage = @"服务器未响应";
        }
        else if (statusCode == 404) {
            
            errorMessage = @"404 error";
            
        }else if (statusCode == 401) {//登录过期
            
            DataWrapper *responseDataWrapper = [DataWrapper dataWrapperWithObject:deserializedData];
            NSString *mess = [responseDataWrapper stringForKey:@"message"];

            //如果是token过期  退出登录
            if ([mess isEqualToString:@"Expired token."]) {
                [[UserManager defaultManager] logOut];
            }
            
        }
        
        
        
        if (deserializedData) {
            DataWrapper *responseDataWrapper = [DataWrapper dataWrapperWithObject:deserializedData];
            NSString *mess = [responseDataWrapper stringForKey:@"message"];
            if (mess.length) {
                errorMessage = mess;
            }
        }
        requestEn.statusCode = statusCode;
        requestEn.messageString = errorMessage;
        NSLog(@"%@",requestEn.messageString);
        requestEn.requestStatus = RequestStatusFailed;
        requestEn.failedBlock(requestEn, error);
        
    };
    
    
    AFHTTPRequestOperation *requestOperation = nil;
    
    
    NSString *methodString = @"";
    
    switch (methodType) {
        case RequestMethodTypeGet:{
            methodString = @"GET";
            break;
        }
        case RequestMethodTypePost:{
            methodString = @"POST";
            break;
        }
        case RequestMethodTypePatch:{
            methodString = @"PATCH";
            break;
        }
        case RequestMethodTypeDelete:{
            methodString = @"DELETE";
            break;
        }
        case RequestMethodTypePut:{
            methodString = @"PUT";
            break;
        }
            
        default:{
            methodString = @"GET";
            break;
        }
    }
    
    if (requestEn.requestMthod == RequestMethodTypeGet) {
        
        requestOperation = [manager GET:requestEn.urlString parameters:requestEn.pargramDic success:successBlock failure:failedBlock];
        
    }else{
        
        NSMutableURLRequest *req = [requestSerializer multipartFormRequestWithMethod:methodString URLString:requestEn.urlString parameters:requestEn.pargramDic constructingBodyWithBlock:requestEn.fileUploadBlock error:nil];
        
        requestOperation = [manager HTTPRequestOperationWithRequest:req success:successBlock failure:failedBlock];
        
        if (requestEn.uploadProgressBlock) {
            [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                NSLog(@"%f", (CGFloat)totalBytesWritten / totalBytesExpectedToWrite);
                requestEn.uploadProgressBlock(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
                requestEn.uploadPercent = (CGFloat)totalBytesWritten / totalBytesExpectedToWrite;

            }];
        }
        
        
    }
    
    
    requestEn.currentRequestOperation = requestOperation;
    requestEn.requestStatus = RequestStatusStart;
    
    [requestOperation start];
    requestStartTime = [NSDate date];
    
}



#pragma mark - Public Method

- (void)requestWithEntity:(RequestEntity *)requestEn
{
    NSString *authorizationHeaderStr = @"";
    if (requestEn.shouldAuth) {
        authorizationHeaderStr = [UserManager defaultManager].ssoToken;
        authorizationHeaderStr = authorizationHeaderStr ? authorizationHeaderStr : @"";
    }
    
    [self httpRequestWithUrl:requestEn.urlString method:requestEn.requestMthod authorizationHeader:authorizationHeaderStr prames:requestEn.pargramDic entity:requestEn];
    
}


#pragma mark - 判断网络类型
- (void)startMonitor{
    self.afNetManager = [AFNetworkReachabilityManager sharedManager];
    [self.afNetManager startMonitoring];
    self.currentNetState = self.afNetManager.networkReachabilityStatus;
    __weak NetworkManager *bSelf = self;
    [self.afNetManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (bSelf.currentNetState != status) {
            CLog(@"%@",@"网络状态改变");
            bSelf.currentNetState = status;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWORKSATECHANGE object:nil];
        }
    }];
}



@end
