//
//  RequestEntity.m
//  LeFilm
//
//  Created by Will Zhang on 15/4/16.
//  Copyright (c) 2015年 LEVP. All rights reserved.
//


#import "RequestEntity.h"
#import "NetworkManager.h"


@interface RequestEntity()

@property (nonatomic, assign)CGFloat uploadPercent;

///取消请求
- (void)cancel;


@end


@implementation RequestEntity


+ (RequestEntity *)entityWithUrlString:(NSString *)urlStr methodType:(RequestMethodType)methodType successBlock:(RequestEntitySuccessBlock)successBlock failedBlock:(RequestEntityFailedBlock)failedBlock
{
    RequestEntity *entity = [[RequestEntity alloc] init];
    entity.urlString = urlStr;
    entity.requestMthod = methodType;
    entity.successBlock =  successBlock;
    entity.failedBlock = failedBlock;
    return entity;
}

+ (RequestEntity *)entityWithUrlString:(NSString *)urlStr methodType:(RequestMethodType)methodType successBlock:(RequestEntitySuccessBlock)successBlock failedBlock:(RequestEntityFailedBlock)failedBlock cancelBlock:(RequestEntityCancelBlock)cancelBlock{
    RequestEntity *entity = [RequestEntity entityWithUrlString:urlStr methodType:methodType successBlock:successBlock failedBlock:failedBlock];
    entity.cancelBlock = cancelBlock;
    return entity;
}

+ (RequestEntity *)entityWithUrlString:(NSString *)urlStr methodType:(RequestMethodType)methodType fileUploadBlock:(RequestEntityFileUploadBlock)fileUploadBlock uploadProgressBlock:(RequestEntityFileUploadProgressBlock)uploadProgressBlock successBlock:(RequestEntitySuccessBlock)successBlock failedBlock:(RequestEntityFailedBlock)failedBlock{
    RequestEntity *entity = [[self class] entityWithUrlString:urlStr methodType:methodType successBlock:successBlock failedBlock:failedBlock];
    entity.fileUploadBlock = fileUploadBlock;
    entity.uploadProgressBlock = uploadProgressBlock;
    return entity;
}




- (void)cancel
{
    if (self.cancelBlock) {
        self.cancelBlock(self);
    }
    
    self.requestStatus = RequestStatusCanceled;
    [self.currentRequestOperation cancel];
}


///取消正在请求的 aEntity请求
+ (void)cancelEntityIfThatIsLoading:(RequestEntity *)aEntity
{
    if (aEntity && aEntity.currentRequestOperation.isExecuting) {
        [aEntity cancel];
    }
}


#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self) {
        _requestStatus = RequestStatusAdded;
        _requestMthod = RequestMethodTypeGet;
        _shouldAuth = YES;
        _isMyApplication = YES;
        _uploadPercent = 0.f;
        _showWErrorMessage = NO;
    }
    return self;
}


#pragma mark - 开始请求

- (void)startConnect
{
    [[NetworkManager sharedManager] requestWithEntity:self];
}


#pragma mark - Desc
- (NSString *)description{
    return [NSString stringWithFormat:@"URL:%@\npragramDic:%@", self.urlString, self.pargramDic];
}

@end
