//
//  ZHBaseService.m
//  ZHNetWorking
//
//  Created by autohome on 2017/12/5.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHBaseService.h"
#import "ZHProxyManager.h"
#import "ZHTamperGuard.h"
#import "ZHNetworkConst.h"
#define BaseServiceDebugLog(sentence) if(self.enableLog){sentence}

@interface ZHBaseService()<ZHRequestDelegate>

@property(nonatomic, assign) NSUInteger retryCount;
@property(nonatomic, assign) NSUInteger expireRetryCount;

@end

@implementation ZHBaseService


- (instancetype)init {
    if (self = [super init]) {
        [self initProperties];
    }
    return self;
}

#pragma mark --- INIT
- (void)initProperties {
    self.priority = ZHRequest_Priority_Default;
    self.timeoutSeconds = 10;
    ///////////////////////
    self.enableLog = NO;
    self.enableMD5 = YES;
    self.enableProxy = NO;
    self.enableRetry = YES;
    self.enableHttpDns = NO;
    self.enableTamperGuard = YES;
    /////////////////////////
}

#pragma mark ---SETTER


#pragma mark --- GET 请求
- (void)GET:(NSURL *)url {
    _requestUrlStr = [url absoluteString];
    _requestMethod = @"GET";
    
    BaseServiceDebugLog(NSLog(@"原始requstUrl------------------>%@",[url absoluteString]););
    
    NSURL *tempUrl = nil;
    /** 如果允许走反向代理，则对url进行处理：反劫持模块处理过的URL*/
    if (self.enableProxy) {
//        tempUrl = //// 反向代理处理url
    } else {
        _requestUrlStr = [url absoluteString];
        tempUrl = url;
    }
    
//    [self initGETHttpMethod:url readPolicy:readPolicy writePolicy];
    [self initGETHttpRequest:url];
}

- (void)initGETHttpRequest:(NSURL *)url {
    /** 对于下拉刷新的请求，需要重置所有请求信息 */
    /** 清除requestHeader中的host信息 */
    if (self.requestHeaderDic && self.requestHeaderDic[@"Host"]) {
        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:self.requestHeaderDic];
        [mDic removeObjectForKey:@"Host"];
        self.requestHeaderDic = [mDic copy];
        BaseServiceDebugLog(NSLog(@"删除Host的值"););
    }

    self.retryCount = 0; // 超时重试和过期重试次数置为 0
    self.expireRetryCount = 0;
    
    [self clearRequest];
    
    ZHRequest *request = [[ZHRequest alloc] init];
    request.delegate = self;
    request.requestUrlStr = [url absoluteString];
    request.requestHeaders = self.requestHeaderDic;
    request.requestHostType = ZHRequest_HostType_INIT;
    request.requestType = ZHRequest_Type_GET;
    request.timeoutInterval = self.timeoutSeconds;
    request.priority = self.priority;
   
    _request = request;
    [_request start];
    
}

#pragma mark --- POST 请求
- (void)POST:(NSURL *)url params:(NSDictionary *)params formData:(ConstructingFormDataBlock)formData {
    _requestUrlStr = [url absoluteString];
    _requestMethod = @"POST";
    
}

- (void)POST:(NSURL *)url params:(NSDictionary *)params {
    [self POST:url params:params formData:nil];
}

#pragma mark --- 需要子类实现
- (BOOL)parseJSON:(NSString *)jsonStr {
    return YES;
}

- (void)clearRequest {
    if (self.request) {
        [self.request cancel];
        self.request.delegate = nil;
    }
}

#pragma mark --- ZHRequestDelegate
- (void)requestWillStart:(NSInteger)handle {
    if ([self.delegate respondsToSelector:@selector(requestWillStart:)]) {
        dispatch_main_queue_excute(^{
            [self.delegate requestWillStart:self.handle];
        });
    }
}

- (void)requestFinished:(NSString *)responseStr
             serviceObj:(id)obj
                 handle:(NSInteger)handle {
    BaseServiceDebugLog(NSLog(@"接口请求成功===============%@",responseStr););
    
}

- (void)requestFinished:(NSData *)responseData
            responseStr:(NSString *)responseStr
             serviceObj:(id)obj
                 handle:(NSInteger)handle {
    
}

- (void)requestFailed:(NSError *)error
           serviceObj:(id)obj
               handle:(NSInteger)handle {
    
}

- (void)requestFailed:(NSError *)error
            errorCode:(NSUInteger)errorCode
             errorMsg:(NSString *)errorMsg
           serviceObj:(id)obj
               handle:(NSInteger)handle {
    
}

- (void)requestWillRetry:(id)serviceObj handle:(NSInteger)handle isAsync:(BOOL)async {
    
}


- (void)requestRedirected:(id)serviceObj handle:(NSInteger)handle {
    
}

@end
