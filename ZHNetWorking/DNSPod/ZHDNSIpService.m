//
//  ZHDNSIpService.m
//  ZHNetWorking
//
//  Created by autohome on 2017/9/28.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHDNSIpService.h"
#import "ZHRequest.h"
#import "ZHDNSHttpManager.h"
#import "ZHDNSResolveItem.h"
#import "ZHRequestManager.h"
@interface ZHDNSIpService()<ZHRequestDelegate>

@end

@implementation ZHDNSIpService

- (instancetype)initWithResolveItem:(ZHDNSResolveItem *)item {
    if (self = [super init]) {
        self.item = item;
    }
    return self;
}


- (void)resolve {
    
    NSTimeInterval crtInterval = [[NSDate date] timeIntervalSince1970];
    
    // 如果是在5分钟内，并且网络环境没有发生变化，则不处理，如果网络环境发生变化则需要重发
    if (crtInterval-self.lastUpdateTime < [ZHDNSHttpManager sharedManager].intime&&self.isNetStatusChanged==NO) {
        return;
    }
    if (self.isNetStatusChanged) {
        self.isNetStatusChanged = NO;
    }
    // 设置解析状态
    self.item.resolveStatus = DNSResolveStatus_Resolving;
    
    ZHRequest *request = [[ZHRequest alloc] init];
    NSString *urlStr = [NSString stringWithFormat:@"http://119.29.29.29/d?ttl=1&dn=%@",self.item.domain];
    request.urlString = urlStr;
    request.responseSerilalizerType = ZHRequest_ResponseSerilalizerType_HTTP;
    request.delegate = self;
    [[ZHRequestManager sharedManager] addRequest:request];
}

- (void)analysisResponseStr:(NSString *)responseStr isFromCache:(BOOL)isCache {
    
}



- (void)requestFinished:(ZHRequest *)request responseStr:(NSString *)responseStr {
    
}

- (void)requestFailed:(NSError *)error {
    
}


@end
