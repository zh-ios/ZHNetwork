//
//  ZHRequestManager.m
//  ZHNetWorking
//
//  Created by autohome on 2017/9/12.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHRequestManager.h"
#import <pthread/pthread.h>
#import "ZHRequest.h"
#import "AFNetworking.h"

#define Lock            pthread_mutex_lock(&_lock)
#define UnLock          pthread_mutex_unlock(&_lock)

@interface ZHRequestManager ()

@property(nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;
@property(nonatomic, strong) AFJSONResponseSerializer *responseSerializer;
@property(nonatomic, strong) AFHTTPSessionManager *manager;
@end

@implementation ZHRequestManager
{
    NSMutableDictionary *_recordRequests;
    pthread_mutex_t _lock;
    
}

+ (instancetype)sharedManager {
    static ZHRequestManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[self alloc] init];
        }
    });
    return _manager;
}

#pragma mark --getter&setter
- (AFHTTPRequestSerializer *)requestSerializer {
    if (!_requestSerializer) {
        _requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _requestSerializer;
}
- (AFJSONResponseSerializer *)responseSerializer {
    if (!_responseSerializer) {
        _responseSerializer = [AFJSONResponseSerializer serializer];
//        _responseSerializer.acceptableStatusCodes = 
    }
    return _responseSerializer;
}
- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _recordRequests = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addRequest:(ZHRequest *)request {
    if (!request) return;

    NSURLSessionTask *dataTask = nil;
    dataTask = [self sessionTask4Request:request];
    [dataTask resume];
    
    Lock;
    [_recordRequests setObject:request forKey:@(request.dataTask.taskIdentifier)];
    UnLock;
    
}

- (NSURLSessionTask *)sessionTask4Request:(ZHRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializer4Request:request];
    NSString *urlStr = request.urlString;
    NSDictionary  *params = request.params;
    NSURLSessionTask *task = nil;
    NSError *error = nil;
    switch (request.requestType) {
        case ZHRequest_Type_GET:
            return [self dataTaskWithHttpMethod:@"GET" requestSerializer:requestSerializer urlStr:urlStr  params:params constructingBlock:request.formData error:error];
            break;
        case ZHRequest_Type_POST:
            return [self dataTaskWithHttpMethod:@"POST" requestSerializer:requestSerializer urlStr:urlStr params:params constructingBlock:request.formData error:error];
            break;
        default:
            break;
    }
    return task;
}

- (AFHTTPRequestSerializer *)requestSerializer4Request:(ZHRequest *)request {
    AFHTTPRequestSerializer *serializer = nil;
    switch (request.requestSerializerType) {
        case ZHRequest_RequestSerializerType_HTTP:
            // TODO
            break;
        case ZHRequest_RequestSerializerType_JSON:
            serializer = [AFJSONRequestSerializer serializer];
            break;
            
        default:
            break;
    }
    serializer.timeoutInterval = request.timeoutInterval;
    
    // If api needs server username and password
    // TODO
    if (request.requestHeaders) {
        for (NSString *key in request.requestHeaders.allKeys) {
            [serializer setValue:request.requestHeaders[key] forHTTPHeaderField:key];
        }
    }
    return serializer;
    
}

- (NSURLSessionDataTask *)dataTaskWithHttpMethod:(NSString *)method requestSerializer:(AFHTTPRequestSerializer *)serializer
                                          urlStr:(NSString *)url
                                          params:(id)params
                               constructingBlock:(ConstructingFormDataBlock)formdata
                                           error:(NSError *)error {
    
    NSMutableURLRequest *request =  nil;
    if (formdata) {
        request = [serializer multipartFormRequestWithMethod:method URLString:url parameters:params constructingBodyWithBlock:formdata error:&error];
    } else {
        request = [serializer requestWithMethod:method URLString:url parameters:params error:&error];
    }
    
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        // 处理返回的结果
    }];
    return dataTask;
}











- (void)sendRequest:(ZHRequest_Type)type url:(NSString *)url
             params:(NSDictionary *)params
     requestHeaders:(NSDictionary *)headers
           formData:(ConstructingFormDataBlock)formData
            process:(ProcessBlock)process
            success:(SuccessBlock)success
            failure:(FailureBlock)failure {
    
}

@end
