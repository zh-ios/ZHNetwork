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
#import "ZHRequestManager.h"
@interface ZHDNSIpService()<ZHRequestDelegate>

@property(nonatomic, strong) ZHDNSResolveItem *item;

@end

@implementation ZHDNSIpService

- (instancetype)initWithResolveItem:(ZHDNSResolveItem *)item {
    if (self = [super init]) {
        self.item = item;
        self.domain = item.domain;
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
    request.requestUrlStr = urlStr;
    request.responseSerilalizerType = ZHRequest_ResponseSerilalizerType_HTTP;
    request.delegate = self;
    [[ZHRequestManager sharedManager] addRequest:request];
}

- (void)analysisResponseStr:(NSString *)responseStr isFromCache:(BOOL)isCache {
    
}



- (void)requestFinished:(ZHRequest *)request responseStr:(NSString *)responseStr {
    if (responseStr && responseStr.length > 0) {
        self.item.resolveStatus = DNSResolveStatus_Done;
        self.resolveStatus = DNSResolveStatus_Done;
        [self handleResponseStr:responseStr fromCache:NO];
        
    } else {
        self.item.resolveStatus = DNSResolveStatus_Failed;
        self.resolveStatus = DNSResolveStatus_Done;
    }
}


- (void)handleResponseStr:(NSString *)responseStr fromCache:(BOOL)fromCache{
//    111.13.101.208;220.181.57.217;123.125.114.144,129
    NSArray *tempArr = [responseStr componentsSeparatedByString:@","];
    if (tempArr.count > 0) {
         NSArray *ipArr = [tempArr[0] componentsSeparatedByString:@";"];
        NSMutableArray *tempResolveItemArr = [NSMutableArray array];
         // 如果有多个可用的ip 地址 只取前两个
        for (int i = 0; i<ipArr.count; i++) {
            if (i > 1) break;
            ZHDNSResolveItem *item = [[ZHDNSResolveItem alloc] init];
            item.resolveStatus = DNSResolveStatus_Done;
            item.domain = self.item.domain;
            item.ipAddr = ipArr[i];
            
            [tempResolveItemArr addObject:item];
            
        }
        
        for (int i = 0; i<tempResolveItemArr.count; i++) {
            ZHDNSResolveItem *newItem = tempResolveItemArr[i];
            for (int j = 0; j<self.resolveItemArr.count; j++) {
                // 如果新的item 在之前的itemsArr 中已经存在则需要继承其是否可用状态
                ZHDNSResolveItem *oldItem = self.resolveItemArr[j];
                if ([newItem.ipAddr isEqualToString:oldItem.ipAddr]) {
                    newItem.resolveStatus = oldItem.resolveStatus;
                    break;
                }
            }
        }
        
        if (tempResolveItemArr.count > 0) {
            self.resolveItemArr = [tempResolveItemArr copy];
            if (fromCache) {
                self.lastUpdateTime = [[NSDate date] timeIntervalSince1970] - 60*60;
            } else {
                self.lastUpdateTime = [[NSDate date] timeIntervalSince1970];
            }
        }
    }
}

- (void)requestFailed:(NSError *)error {
    
}


@end
