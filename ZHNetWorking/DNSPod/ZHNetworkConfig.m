//
//  ZHNetworkConfig.m
//  ZHNetWorking
//
//  Created by autohome on 2017/9/29.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHNetworkConfig.h"

@implementation ZHNetworkConfig

- (instancetype)init {
    if (self = [super init]) {
        self.isUseDNSPod = YES;
    }
    return self;
}

@end
