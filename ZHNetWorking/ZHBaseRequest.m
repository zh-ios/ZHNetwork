//
//  ZHHttpRequst.m
//  ZHNetWorking
//
//  Created by autohome on 2017/8/2.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHBaseRequest.h"

@interface ZHBaseRequest ()

@end

@implementation ZHBaseRequest

- (instancetype)init {
    if (self = [super init]) {
        self.timeoutSeconds = 30;
    }
    return self;
}

- (NSHTTPURLResponse *)httpResponse {
    return (NSHTTPURLResponse *)self.requestTask.response;
}
- (NSInteger)responseStatusCode {
    return self.httpResponse.statusCode;
}
- (NSDictionary *)responseHeaders {
    return self.httpResponse.allHeaderFields;
}
- (NSURLRequest *)originRequest {
    return self.requestTask.originalRequest;
}
- (NSURLRequest *)crtRequest {
    return self.requestTask.currentRequest;
}


#pragma mark -- 子类重写
- (id)params {
    return nil;
}
- (ZHRequestType)requestType {
    return ZHRequestType_GET;
}
- (ZHRequestSerializerType)requestSerializer {
    return ZHRequestSerializerType_JSON;
}
- (ZHResponseSerializerType)responseSerializer {
    return ZHResponseSerializerType_JSON;
}

@end
