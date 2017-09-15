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

@property(nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
@property(nonatomic, strong) AFHTTPResponseSerializer *httpResponseSerializer;
@property(nonatomic, strong) AFXMLParserResponseSerializer *xmlResponseSerializer;

@property(nonatomic, strong) AFHTTPSessionManager *manager;
@property(nonatomic, strong) NSIndexSet *statusCodeRange;
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
- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _jsonResponseSerializer.acceptableStatusCodes = self.statusCodeRange;
    }
    return _jsonResponseSerializer;
}
- (AFHTTPResponseSerializer *)httpResponseSerializer {
    if (!_httpResponseSerializer) {
        _httpResponseSerializer = [AFHTTPResponseSerializer serializer];
        _httpResponseSerializer.acceptableStatusCodes = self.statusCodeRange;
    }
    return _httpResponseSerializer;
}
- (AFXMLParserResponseSerializer *)xmlResponseSerializer {
    if (!_xmlResponseSerializer) {
        _xmlResponseSerializer = [AFXMLParserResponseSerializer serializer];
        _xmlResponseSerializer.acceptableStatusCodes = self.statusCodeRange;
    }
    return _xmlResponseSerializer;
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
        
        
        // 返回的结果是二进制类型
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.statusCodeRange = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        // take over response status range
        self.manager.responseSerializer.acceptableStatusCodes = self.statusCodeRange;
    }
    return self;
}

- (void)addRequest:(ZHRequest *)request {
    if (!request) return;

    // 判断是否是同一个request ，如果是同一个requst 先取消之前的请求。
    Lock;
    ZHRequest *oldRequest = [_recordRequests objectForKey:request.uniqueIdentifier];
    UnLock;
    if (oldRequest) {
        [oldRequest cancel];
    }
    NSURLSessionTask *sessionTask = nil;
    sessionTask = [self sessionTask4Request:request];
    request.sessionTask = sessionTask;
    
    // 设置sesssion的优先级
    if ([request.sessionTask respondsToSelector:@selector(priority)]) {
        switch (request.priority) {
            case ZHRequest_Priority_Low:
                request.sessionTask.priority = NSURLSessionTaskPriorityLow;
                break;
            case ZHRequest_Priority_Default:
                request.sessionTask.priority = NSURLSessionTaskPriorityDefault;
                break;
            case ZHRequest_Priority_High:
                request.sessionTask.priority = NSURLSessionTaskPriorityHigh;
                break;
                
            default:
                break;
        }
    }
    
    [sessionTask resume];
    
    Lock;
    [_recordRequests setObject:request forKey:request.uniqueIdentifier];
    UnLock;
    
}

- (NSURLSessionTask *)sessionTask4Request:(ZHRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializer4Request:request];
    NSString *urlStr = request.urlString;
    NSDictionary  *params = request.params;
    NSURLSessionTask *task = nil;
    NSError *error = nil;
    task = [self dataTask4Request:request requestSerializer:requestSerializer urlStr:urlStr params:params constructingBlock:request.formData error:error];
   
    return task;
}

- (AFHTTPRequestSerializer *)requestSerializer4Request:(ZHRequest *)request {
    AFHTTPRequestSerializer *serializer = nil;
    switch (request.requestSerializerType) {
            // default 
        case ZHRequest_RequestSerializerType_HTTP:
            serializer = [AFHTTPRequestSerializer serializer];
            break;
        case ZHRequest_RequestSerializerType_JSON:
            serializer = [AFJSONRequestSerializer serializer];
            break;
        case ZHRequest_RequestSerializerType_Plist:
            serializer = [AFPropertyListRequestSerializer serializer];
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

- (NSURLSessionDataTask *)dataTask4Request:(ZHRequest *)request requestSerializer:(AFHTTPRequestSerializer *)serializer
                                          urlStr:(NSString *)url
                                          params:(id)params
                               constructingBlock:(ConstructingFormDataBlock)formdata
                                           error:(NSError *)error {
    
    NSMutableURLRequest *urlRequest =  nil;
    NSString *method = @"GET";
    switch (request.requestType) {
        case ZHRequest_Type_GET:
            method = @"GET";
            break;
        case ZHRequest_Type_POST:
            method = @"POST";
            break;
        default:
            break;
    }
    
    if (formdata) {
        urlRequest = [serializer multipartFormRequestWithMethod:method URLString:url parameters:params constructingBodyWithBlock:formdata error:&error];
    } else {
        urlRequest = [serializer requestWithMethod:method URLString:url parameters:params error:&error];
    }

    NSURLSessionDataTask *dataTask = [self.manager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        // 处理返回的结果
        [self handleResult:request urlResponse:response responseObj:responseObject error:error];
    }];
    
    return dataTask;
}


- (void)handleResult:(ZHRequest *)request urlResponse:(NSURLResponse *)response responseObj:(id)responseObj error:(NSError *)error {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    request.statusCode = httpResponse.statusCode;
    request.allHeaderFields = httpResponse.allHeaderFields;
 
    request.responseObj = responseObj;
    if ([responseObj isKindOfClass:[NSData class]]) {
        request.responseObj = responseObj;
        NSError *serializerError = nil;
        switch (request.responseSerilalizerType) {
            case ZHRequest_ResponseSerilalizerType_JSON:
                request.responseObj = [self.jsonResponseSerializer responseObjectForResponse:response data:responseObj error:&serializerError];
                request.responseString = [[NSString alloc] initWithData:responseObj encoding:NSUTF8StringEncoding];
                break;
            case ZHRequest_ResponseSerilalizerType_HTTP:
                //
                request.responseObj = [self.httpResponseSerializer responseObjectForResponse:response data:responseObj error:&serializerError ];
                request.responseString = [[NSString alloc] initWithData:responseObj encoding:NSUTF8StringEncoding];
                break;
            case ZHRequest_ResponseSerilalizerType_XML:
                //
                break;
            default:
                break;
        }
    }
}









- (void)cancelRequest:(ZHRequest *)request {
    if (!request) return;
    NSURLSessionTask *sessionTask = request.sessionTask;
    [sessionTask cancel];
    Lock;
    [_recordRequests removeObjectForKey:request.uniqueIdentifier];
    UnLock;
}

- (void)cancelAllRequest {
    Lock;
    NSArray *keys = _recordRequests.allKeys;
    UnLock;
    if (keys && keys.count > 0) {
        NSArray *keysCopy = [keys copy];
        for (NSString *key in keysCopy) {
            Lock;
            ZHRequest *request = _recordRequests[key];
            UnLock;
            [request cancel];
            request = nil;
        }
    }
}

@end
