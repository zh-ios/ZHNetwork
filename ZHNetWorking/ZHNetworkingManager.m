//
//  ZHNetworkingManager.m
//  ZHNetWorking
//
//  Created by autohome on 2017/11/20.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHNetworkingManager.h"
#import "ZHDNSHttpManager.h"
#import "ZHTamperConfig.h"
@interface ZHNetworkingManager()

@end

@implementation ZHNetworkingManager

+ (instancetype)sharedManager {
    static ZHNetworkingManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[self alloc] init];
        }
    });
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        // 初始化的时候就去获取domainlist 
        [[ZHDNSHttpManager sharedManager] getAllDomain];
    }
    return self;
}

- (NSArray *)getAllDomainList {
    return [[ZHDNSHttpManager sharedManager] getAllDomainList];
}

- (void)addDomainsAndRefresh:(NSArray *)domains {
    if ([[ZHTamperConfig sharedConfig] enableHttpDns]) {
        [[ZHDNSHttpManager sharedManager] addDomainAndRefresh:domains];
    }
}

- (NSString *)getIpUrlStrWithReallyUrlStr:(NSString *)reallyUrlStr requestUrlStr:(NSString *)urlStr {
    if ([ZHTamperConfig sharedConfig].enableHttpDns) {
        return  [[ZHDNSHttpManager sharedManager] getIpUrlStrWithReallyUrlStr:reallyUrlStr requestUrlStr:urlStr];
    } else {
        return reallyUrlStr;
    }
}

- (void)setIpInvalidate:(NSString *)reallyUrlStr requestUrlStr:(NSString *)urlStr {
    [[ZHDNSHttpManager sharedManager] setIpInvalidate:reallyUrlStr requestUrlStr:urlStr];
}

@end
