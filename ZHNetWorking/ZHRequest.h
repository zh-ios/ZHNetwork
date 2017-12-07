//
//  ZHRequest.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/12.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "AFNetworking.h"
#import "ZHRequestDelegate.h"

typedef NS_ENUM(NSInteger, ZHRequest_HostType) {
    ZHRequest_HostType_INIT = 0, // 初始请求域名
    ZHRequest_HostType_DNSPOD,  // DNSPOD 域名请求
    ZHRequest_HostType_PROXY // 反向代理域名
};

typedef NS_ENUM(NSInteger, ZHRequest_Retry_Type) {
    ZHRequest_Retry_Type_INIT = 0, // 初始请求
    ZHRequest_Retry_Type_Retry,   // 重试请求
    ZHRequest_Retry_Type_Other   // 其他请求 异步重试的请求
};

typedef NS_ENUM(NSInteger, ZHRequest_Type) {
    ZHRequest_Type_GET = 0,
    ZHRequest_Type_POST
};

typedef NS_ENUM(NSInteger, ZHRequest_RequestSerializerType) {
    // 二进制格式 default 
    ZHRequest_RequestSerializerType_HTTP = 0,
    // json
    ZHRequest_RequestSerializerType_JSON,
    // plist
    ZHRequest_RequestSerializerType_Plist
    
};

typedef NS_ENUM(NSInteger, ZHRequest_Priority) {
    ZHRequest_Priority_Default = 0,
    ZHRequest_Priority_High,
    ZHRequest_Priority_Low
};

typedef NS_ENUM(NSInteger, ZHRequest_ResponseSerilalizerType) {
    // JSON Obj
    ZHRequest_ResponseSerilalizerType_JSON = 0,
    // Data Type
    ZHRequest_ResponseSerilalizerType_HTTP,
    // NSXMLParse Type
    ZHRequest_ResponseSerilalizerType_XML
    
};

typedef void (^ConstructingFormDataBlock)(id<AFMultipartFormData> formData);
typedef void (^SuccessBlock) (id responseObj);
typedef void (^FailureBlock) (NSError *error);
typedef void (^DownloadProcessBlock)(NSProgress *process);

@interface ZHRequest : NSObject <ZHRequestDelegate>

@property(nonatomic, strong) NSURLSessionTask *sessionTask;
@property(nonatomic, assign) NSInteger statusCode;
/*!
 @property
 @abstract a dictionary containing all the HTTP header fields
 of the receiver.
 */
@property(nonatomic, strong) NSDictionary *allHeaderFields;
@property(nonatomic, strong) id responseObj;
@property(nonatomic, strong) NSData *responseData;
@property(nonatomic, copy)   NSString *responseString;
/*!
 @property
 @abstract 唯一标示
 */
@property(nonatomic, copy) NSString *uniqueIdentifier;

/*!
 @property
 @abstract 实际发出请求的时候urlStr
 */
@property(nonatomic, copy) NSString *requestUrlStr;
@property(nonatomic, assign) NSInteger timeoutInterval;
@property(nonatomic, strong) NSDictionary *params;




/*!
 @property
 @abstract 自定义的请求头参数
 */
@property(nonatomic, strong) NSDictionary *requestHeaders;

/*!
 @property
 @abstract 默认get
 */
@property(nonatomic, assign) ZHRequest_Type requestType;
/*!
 @property
 @abstract 请求的类型：是走的初始请求，反向代理，还是走的dnspod
 */
@property(nonatomic, assign) ZHRequest_HostType requestHostType;
/*!
 @property
 @abstract 重试次数类型，是第一次还是重试 
 */
@property(nonatomic, assign) ZHRequest_Retry_Type requestRetryType;
/*!
 @property
 @abstract 默认 http
 */
@property(nonatomic, assign) ZHRequest_RequestSerializerType requestSerializerType;

@property(nonatomic, copy) ConstructingFormDataBlock formData;

@property(nonatomic, assign) ZHRequest_Priority priority;
/*!
 @property
 @abstract 默认JSON
 */
@property(nonatomic, assign) ZHRequest_ResponseSerilalizerType responseSerilalizerType;

/*!
 @property
 @abstract 下载文件的路径，如果设置该属性则会使用 downloadTask ，
 开始下载文件之前会将该路径的文件先移除，支持断点下载如果出现网络错误会保存已经下载的内容，
 同一个下载 url 下次下载时会从上次的基础继续下载 ，
 但是如果下载过程中杀死进程则不会保存已下载的数据。
 */
@property(nonatomic, copy) NSString *downloadPath;
/*!
 @property
 @abstract 下载文件的进度,需要放在主线程中！
 */
@property(nonatomic, copy) DownloadProcessBlock downloadProcess;

/*!
 @property
 @abstract 成功失败的回调
 */
@property(nonatomic, copy) SuccessBlock successBlock;
@property(nonatomic, copy) FailureBlock failureBlock;

@property(nonatomic, weak) id<ZHRequestDelegate> delegate;

@property(nonatomic, assign) BOOL useProxy;

- (void)cancel;

- (void)start;



@end
