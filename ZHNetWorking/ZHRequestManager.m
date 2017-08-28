//
//  ZHRequestManager.m
//  ZHNetWorking
//
//  Created by autohome on 2017/8/3.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHRequestManager.h"
#import "AFNetworking.h"
#import "ZHBaseRequest.h"
#import "AFHttpSessionManager.h"
#import <pthread/pthread.h>

@interface ZHRequestManager ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, ZHBaseRequest *> *requestRecord;
@property(nonatomic, strong) AFHTTPSessionManager *sessionMgr;

@property(nonatomic, strong) AFJSONResponseSerializer  *jsonResponseSerializer;
@end

@implementation ZHRequestManager
{
    pthread_mutex_t _lock;
}

#pragma mark --getter & setter
- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _jsonResponseSerializer;
}

+ (instancetype)sharedManager {
    static ZHRequestManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!mgr) {
            mgr = [[self alloc] init];
        }
    });
    return mgr;
}

- (instancetype)init {
    if (self = [super init]) {
        self.requestRecord = [NSMutableDictionary dictionary];
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (void)addRequest:(ZHBaseRequest *)request {
    NSParameterAssert(request != nil);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [self.requestRecord setObject:request forKey:@(request.requestTask.taskIdentifier)];
    dispatch_semaphore_signal(semaphore);
}


- (NSURLSessionTask *)sessionTask4Request:(ZHBaseRequest *)request error:(NSError * _Nullable __autoreleasing)error {
    ZHRequestType requestType = request.requestType;
    id params = [request params];
    AFConstructingBlock block = request.constructingBodyBlock;
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializer4Request:(ZHBaseRequest *)request];
    switch (request.requestType) {
        case ZHRequestType_GET:
            if (request.downloadPath) {
                // 下载文件
            } else {
                
            }
            break;
        case ZHRequestType_POST:
            break;
        case ZHRequestType_DELETE:
            break;
        default:
            break;
    }
    return  nil;
}

- (NSURLSessionDataTask *)dataTaskWithHttpMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)serializer
                                          urlStr:(NSString *)urlStr
                                          params:(NSDictionary *)params
                                           error:(NSError *_Nullable __autoreleasing)error {
    return [self dataTaskWithHttpMethod:method requestSerializer:serializer urlStr:urlStr params:params constructingBobdyWithBlock:nil error:error];
}

- (NSURLSessionDataTask *)dataTaskWithHttpMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)serializer
                                          urlStr:(NSString *)urlStr
                                          params:(NSDictionary *)params
                      constructingBobdyWithBlock:(void (^)(id<AFMultipartFormData> formData))block
                                           error:(NSError *_Nullable __autoreleasing)error {
    NSMutableURLRequest *request = nil;
    if (block) {
        request = [serializer multipartFormRequestWithMethod:method URLString:urlStr parameters:params constructingBodyWithBlock:block error:&error];
    } else {
        request = [serializer requestWithMethod:method URLString:urlStr parameters:params error:&error];
    }
    NSURLSessionDataTask *task = [self.sessionMgr dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self handleRequestResult:task responseObj:response error:error];
    }];
    return task;
}


- (AFHTTPRequestSerializer *)requestSerializer4Request:(ZHBaseRequest *)request {
    AFHTTPRequestSerializer *serializer = nil;
    if ([request requestSerializer] == ZHRequestSerializerType_JSON) {
        serializer = [AFJSONRequestSerializer serializer];
    }
    serializer.timeoutInterval = request.timeoutSeconds;
    
    NSDictionary<NSString *, NSString *> *customHeaders = request.requstHeaders;
    if (customHeaders) {
        for (NSString *key in customHeaders.allKeys) {
            NSString *value = customHeaders[key];
            [serializer setValue:value forHTTPHeaderField:key];
        }
    }
    return serializer;
}


- (void)handleRequestResult:(NSURLSessionTask *)task responseObj:(id)response error:(NSError * _Nullable __autoreleasing)error {
    pthread_mutex_lock(&_lock);
    ZHBaseRequest *request = self.requestRecord[@(task.taskIdentifier)];
    pthread_mutex_unlock(&_lock);
    if (!request) return;
    request.responseData = response;
    NSError *serializationError = nil;
    NSError *validationError = nil;
    NSError *requestError = nil;
    BOOL success = NO;
    switch (request.requestSerializer) {
        case ZHRequestSerializerType_JSON:
            request.responseObj =  [self.jsonResponseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
            break;
            
        default:
            break;
    }
    
    if (error) {
        success = NO;
        requestError = error;
    } else if (serializationError) {
        success = NO;
        requestError = error;
    } else {
        // 验证json 合法性
//        success = [request validateJson: error:];
        requestError = validationError;
    }
    
    if (success) {
        // 成功回调
    } else {
        // 失败回调
    }
    
    
    
}

- (void)removeRequestFromRecord:(ZHBaseRequest *)request {
    pthread_mutex_lock(&_lock);
    [self.requestRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
    pthread_mutex_unlock(&_lock);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRequestFromRecord:request];
        [self clearCompletionBlock];
    });
    
    
}

- (void)clearCompletionBlock {
    // 设置回调blcok 为nil
}

- (void)cancelAllRequests {
    pthread_mutex_lock(&_lock);
    NSArray *allKeys = [self.requestRecord allKeys];
    pthread_mutex_unlock(&_lock);
    for (NSNumber *key in allKeys) {
        pthread_mutex_lock(&_lock);
        ZHBaseRequest *request = self.requestRecord[key];
        pthread_mutex_unlock(&_lock);
        [request stop];
    }
}

- (void)cancelRequest:(ZHBaseRequest *)request {
    [request.requestTask cancel];
    [self removeRequestFromRecord:request];
    [self clearCompletionBlock];
}

@end
