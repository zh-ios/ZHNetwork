//
//  ZHRequest.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/12.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "AFNetworking.h"
#import "ZHRequestDelegate.h"
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


@property(nonatomic, copy) NSString *urlString;
@property(nonatomic, assign) NSInteger timeoutInterval;
@property(nonatomic, strong) NSDictionary *params;

/*!
 @property
 @abstract 自定义的请求头参数
 */
@property(nonatomic, strong) NSDictionary *requestHeaders;

@property(nonatomic, assign) ZHRequest_Type requestType;

@property(nonatomic, assign) ZHRequest_RequestSerializerType requestSerializerType;

@property(nonatomic, copy) ConstructingFormDataBlock formData;

@property(nonatomic, assign) ZHRequest_Priority priority;

@property(nonatomic, assign) ZHRequest_ResponseSerilalizerType responseSerilalizerType;

/*!
 @property
 @abstract 下载文件的路径，如果设置该属性则会使用 downloadTask ，
 开始下载文件之前会将该路径的文件先移除
 */
@property(nonatomic, copy) NSString *downloadPath;
/*!
 @property
 @abstract 下载文件的进度
 */
@property(nonatomic, copy) DownloadProcessBlock downloadProcess;

@property(nonatomic, weak) id<ZHRequestDelegate> delegate;

- (void)cancel;

- (void)start;



@end
