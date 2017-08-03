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
        self.requestType = ZHRequestType_GET;
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


@end
