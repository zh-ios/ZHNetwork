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
@interface ZHRequestManager ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, ZHBaseRequest *> *requestRecord;
@property(nonatomic, strong) AFHTTPSessionManager *sessionMgr;
@end

@implementation ZHRequestManager

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
    
    switch (request.requestType) {
        case ZHRequestType_GET:
            
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

- (void)handleRequestResult:(NSURLSessionTask *)task responseObj:(id)response error:(NSError * _Nullable __autoreleasing)error {
    
}

- (void)cancelAllRequests {
    
}

- (void)cancelRequest:(ZHBaseRequest *)request {
    
}

@end
