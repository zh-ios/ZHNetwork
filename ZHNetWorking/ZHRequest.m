//
//  ZHRequest.m
//  ZHNetWorking
//
//  Created by autohome on 2017/9/12.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHRequest.h"
#import "ZHRequestManager.h"
@implementation ZHRequest

- (instancetype)init {
    if (self = [super init]) {
        self.requestType = ZHRequest_Type_GET;
        self.requestSerializerType = ZHRequest_RequestSerializerType_HTTP;
        self.timeoutInterval = 60;
        self.uniqueIdentifier = [NSString stringWithFormat:@"uniqueid=%lu",(unsigned long)[self hash]];
    }
    return self;
}

- (void)cancel {
    [[ZHRequestManager sharedManager] cancelRequest:self];
}

- (void)start {
    [[ZHRequestManager sharedManager] addRequest:self];
}

@end
