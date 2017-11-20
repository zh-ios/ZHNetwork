//
//  ZHTamperConfig.m
//  ZHNetWorking
//
//  Created by autohome on 2017/11/14.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHTamperConfig.h"

@implementation ZHTamperConfig

+ (instancetype)sharedConfig {
    static ZHTamperConfig *_config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_config) {
            _config = [[self alloc] init];
        }
    });
    return _config;
}

- (instancetype)init {
    if (self = [super init]) {
        self.enableHttpDns = YES;
        self.enableProxy = YES;
        self.enableTamperGuard = YES;
    }
    return self;
}

@end
