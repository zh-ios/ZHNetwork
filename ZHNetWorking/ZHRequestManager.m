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
    
    // 请求即将开始回调
    if ([request.delegate respondsToSelector:@selector(requestWillStart)]) {
        [request.delegate requestWillStart];
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
    
    NSString *method = @"GET";
    switch (request.requestType) {
        case ZHRequest_Type_GET:
            if (request.downloadPath) {
                return  [self downloadTaskWithRequest:request downloadPath:request.downloadPath requestSerializer:requestSerializer url:request.urlString params:params downloadProcess:request.downloadProcess];
            } else {
                method = @"GET";
            }
            break;
        case ZHRequest_Type_POST:
            method = @"POST";
            break;
        default:
            break;
    }
    
    task = [self dataTask4Request:request method:method  requestSerializer:requestSerializer urlStr:urlStr params:params constructingBlock:request.formData error:error];
   
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

- (NSURLSessionDataTask *)dataTask4Request:(ZHRequest *)request
                                    method:(NSString *)method
                         requestSerializer:(AFHTTPRequestSerializer *)serializer
                                    urlStr:(NSString *)url
                                    params:(id)params
                         constructingBlock:(ConstructingFormDataBlock)formdata
                                     error:(NSError *)error {
    
    NSMutableURLRequest *urlRequest =  nil;

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

/*!
 @method
 @abstract   返回下载任务
 @discussion request 对应的request，传递responseObj 为fileurl，
 传递request 是为了给request中的各个属性赋值 如果 responseStr，responseData等。
 */
- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(ZHRequest *)request
                   downloadPath:(NSString *)path
              requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                            url:(NSString *)url
                         params:(NSDictionary *)params
                downloadProcess:(DownloadProcessBlock)process {
    // 添加请求参数
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:@"GET" URLString:url parameters:params error:nil];
    
    // 保证下载路径 是一个路径，而不是文件夹
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    NSString *targetDownloadPath = nil;
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        targetDownloadPath = [NSString pathWithComponents:@[path, fileName]];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:targetDownloadPath]) {
        // AFN use `moveItemAtURL` to move downloaded file to target path,
        // this method aborts the move attempt if a file already exist at the path.
        // So we remove the exist file before we start the download task.
        // https://github.com/AFNetworking/AFNetworking/issues/3775
        [[NSFileManager defaultManager] removeItemAtPath:targetDownloadPath error:nil];
    }
    
    NSURL *resumeDataUrl = [self incompleteDownloadTempPathForDownloadPath:path];
    NSData *resumeData = [NSData dataWithContentsOfURL:resumeDataUrl];
    
    BOOL isValid = [self validateResumeData:resumeData];
    
    
    if (resumeData && isValid) {
        return [self.manager downloadTaskWithResumeData:resumeData progress:process destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:targetDownloadPath isDirectory:NO];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [self handleResult:request urlResponse:response responseObj:filePath error:error];
        }];
    } else {
        return [self.manager downloadTaskWithRequest:urlRequest progress:process destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:targetDownloadPath isDirectory:NO];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            [self handleResult:request urlResponse:response responseObj:filePath error:error];
        }];
    }
    
}

- (void)handleResult:(ZHRequest *)request urlResponse:(NSURLResponse *)response responseObj:(id)responseObj error:(NSError *)error {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    request.statusCode = httpResponse.statusCode;
    request.allHeaderFields = httpResponse.allHeaderFields;
 
    request.responseObj = responseObj;
    
    NSError *serializerError = nil;
    
    if ([responseObj isKindOfClass:[NSData class]]) {
        request.responseData = responseObj;
        
        switch (request.responseSerilalizerType) {
            case ZHRequest_ResponseSerilalizerType_JSON:
                request.responseObj = [self.jsonResponseSerializer responseObjectForResponse:response data:responseObj error:&serializerError];
                break;
            case ZHRequest_ResponseSerilalizerType_HTTP:
                //
                request.responseObj = [self.httpResponseSerializer responseObjectForResponse:response data:responseObj error:&serializerError ];
                break;
            case ZHRequest_ResponseSerilalizerType_XML:
                //
                break;
            default:
                break;
        }
        if ([responseObj isKindOfClass:[NSData class]]) {
            request.responseString = [[NSString alloc] initWithData:responseObj encoding:NSUTF8StringEncoding];
        } else if ([responseObj isKindOfClass:[NSURL class]]) { // 如果是下载任务
            request.responseString = [((NSURL *)responseObj) absoluteString];
        }
    }

    
    // TODO 返回结果校验
    BOOL isValidResponse = NO;
    if (request.statusCode <= 200 && request.statusCode <= 400) {
        isValidResponse = YES;
    }
    
    BOOL isSuccess = NO;
    if (!error && !serializerError && isValidResponse) {
        isSuccess = YES;
    }
    
    if (isSuccess) {
        /// 请求成功回调
        if ([request.delegate respondsToSelector:@selector(requestFinished:responseObj:)]) {
            [request.delegate requestFinished:request responseObj:request.responseObj];
        }
        if ([request.delegate respondsToSelector:@selector(requestFinished:responseStr:)]) {
            [request.delegate requestFinished:request responseStr:request.responseString];
        }
    } else {
        if ([request.delegate respondsToSelector:@selector(requestFailed:)]) {
            [request.delegate requestFailed:error];
        }
    }
}

- (void)requestDidSuccessWithRequest:(ZHRequest *)request responseObj:(id)responseObj{
    
}
- (void)requestDidFailedWithRequest:(ZHRequest *)request error:(NSError *)error {
    
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


#pragma mark - Resumable Download

- (NSURL *)incompleteDownloadTempPathForDownloadPath:(NSString *)downloadPath {
    NSString *tempPath = [[self incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:downloadPath];
    return [NSURL fileURLWithPath:tempPath];
}

- (NSString *)incompleteDownloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    static NSString *cacheFolder;
    
    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:@"incomplete"];
    }
    
    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

- (BOOL)validateResumeData:(NSData *)data {
    // From http://stackoverflow.com/a/22137510/3562486
    if (!data || [data length] < 1) return NO;
    
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) return NO;
    
    // Before iOS 9 & Mac OS X 10.11
#if (defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED < 90000)\
|| (defined(__MAC_OS_X_VERSION_MAX_ALLOWED) && __MAC_OS_X_VERSION_MAX_ALLOWED < 101100)
    NSString *localFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
    if ([localFilePath length] < 1) return NO;
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
#endif
    // After iOS 9 we can not actually detects if the cache file exists. This plist file has a somehow
    // complicated structue. Besides, the plist structure is different between iOS 9 and iOS 10.
    // We can only assume that the plist being successfully parsed means the resume data is valid.
    return YES;
}

@end
