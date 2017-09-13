//
//  ZHRequest.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/12.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHBaseRequest.h"
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, ZHRequest_Type) {
    ZHRequest_Type_GET = 1,
    ZHRequest_Type_POST
};

typedef NS_ENUM(NSInteger, ZHRequest_RequestSerializerType) {
    ZHRequest_RequestSerializerType_JSON = 1,
    ZHRequest_RequestSerializerType_HTTP
};

typedef void (^ConstructingFormDataBlock)(id<AFMultipartFormData> formData);
typedef void (^ProcessBlock)(NSProgress *process);
typedef void (SuccessBlock) (id responseObj);
typedef void (FailureBlock) (NSError *error);

@interface ZHRequest : NSObject

@property(nonatomic, strong) NSURLSessionDataTask *dataTask;

@property(nonatomic, assign) NSInteger statusCode;

@property(nonatomic, copy) NSString *responseString;

@property(nonatomic, copy) NSString *urlString;

@property(nonatomic, copy) NSString *responseStatusCode;

@property(nonatomic, strong) NSData *responseData;

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

- (void)cancel;

- (void)start;



@end
