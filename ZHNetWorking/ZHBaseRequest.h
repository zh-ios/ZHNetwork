//
//  ZHHttpRequst.h
//  ZHNetWorking
//
//  Created by autohome on 2017/8/2.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AFMultipartFormData;

typedef void (^DownloadPrcessBlock)(NSProgress *process);
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

typedef NS_ENUM(NSUInteger, ZHRequestSerializerType) {
    ZHRequestSerializerType_JSON
};

typedef NS_ENUM(NSUInteger, ZHRequestType) {
    ZHRequestType_GET,
    ZHRequestType_POST,
    ZHRequestType_DELETE
};

typedef NS_ENUM(NSInteger, ZHResponseSerializerType) {
    ZHResponseSerializerType_JSON
};


@interface ZHBaseRequest : NSObject

/*!
 @property
 @abstract 请求的task
 */
@property(nonatomic, strong) NSURLSessionTask *requestTask;

@property(nonatomic, strong) NSData *responseData;

/*!
 @property
 @abstract 返回的字符串
 */
@property(nonatomic, copy, readonly) NSString *responseString;

@property(nonatomic, strong, readonly) NSHTTPURLResponse *httpResponse;
/*!
 @property
 @abstract 文件下载的路径，在请求开始之前会将这个路径下的文件移除，如果请求成功文件将会自动保存包改路径下，否则会保存到 responseData 和 responseString
 */
@property(nonatomic, strong) NSString *downloadPath;
@property(nonatomic, copy) DownloadPrcessBlock processBlock;

@property(nonatomic, copy) AFConstructingBlock  constructingBodyBlock;

/*!
 @property
 @abstract 返回的状态吗
 */
@property(nonatomic, assign, readonly) NSInteger responseStatusCode;
/*!
 @property
 @abstract 服务器返回的请求头
 */
@property(nonatomic, strong, readonly) NSDictionary *responseHeaders;
/*!
 @property
 @abstract 返回的错误信息
 */
@property(nonatomic, strong, readonly) NSError *error;
/*!
 @property
 @abstract 请求urlstr
 */
@property(nonatomic, copy, readonly) NSURLRequest *originRequest;

/* may differ from originalRequest due to http server redirection */
@property(nonatomic, copy, readonly) NSURLRequest *crtRequest;
/*!
 @property
 @abstract 请求的优先级
 */
@property(nonatomic, assign) NSOperationQueuePriority priority;
/*!
 @property
 @abstract 请求超时重试次数
 */
@property(nonatomic, assign) NSInteger timeoutRetryTimes;
/*!
 @property
 @abstract 请求超时时长，单位 s
 */
@property(nonatomic, assign) NSInteger timeoutSeconds;
/*!
 @property
 @abstract get 方式请求服务添加的请求头
 */
@property(nonatomic, strong) NSDictionary *requstHeaders;

/*!
 @method
 @abstract   改变当前请求的优先级
 @discussion 改变当前请求的优先级
 */
- (void)changeCrtRequstPriority;

/*!
 @method
 @abstract   取消并清除请求
 */
- (void)stop;
/*!
 @method
 @abstract   开始请求
 */
- (void)start;

#pragma mark --需求子类重写 
- (id)params;
// 默认get
- (ZHRequestType)requestType;
// 默认json
- (ZHRequestSerializerType)requestSerializer;
// 默认json
- (ZHResponseSerializerType)responseSerializer;
@end
