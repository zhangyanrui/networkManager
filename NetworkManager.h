//
//  NetworkManager.h
//  LeFilm
//
//  Created by Will Zhang on 15/4/16.
//  Copyright (c) 2015年 LEVP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworkReachabilityManager.h>
@class RequestEntity;


typedef enum : NSUInteger {
    RequestStatusAdded,
    RequestStatusStart,
    RequestStatusSuccess,
    RequestStatusFailed,
    RequestStatusCanceled,
} RequestStatus;

typedef enum : NSUInteger{
    RequestMethodTypeGet,
    RequestMethodTypePost,
    RequestMethodTypePut,
    RequestMethodTypePatch,
    RequestMethodTypeDelete,
    RequestMethodTypeUploadFile,
}RequestMethodType;



//连接服务器超时秒数
#define RequestTimeOutSeconds 15

@interface NetworkManager : NSObject



@property (nonatomic, assign) AFNetworkReachabilityStatus currentNetState;//当前网络的状态

//记录accesstoken,供oAuth使用
@property (nonatomic,strong) NSString *accessToken;

//单例 用来管理所有的网络请求
+(NetworkManager *)sharedManager;

//携带实体进行请求
- (void)requestWithEntity:(RequestEntity *)requestEn;

/**
 *  判断网络类型 WiFi 3G....
 */
- (void)startMonitor;

@end
