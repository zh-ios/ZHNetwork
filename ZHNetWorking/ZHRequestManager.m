//
//  ZHRequestManager.m
//  ZHNetWorking
//
//  Created by autohome on 2017/8/3.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHRequestManager.h"
#import "AFNetworking.h"
@interface ZHRequestManager ()

@property(nonatomic, strong) NSMutableDictionary *requestRecord;

@end

@implementation ZHRequestManager

+ (instancetype)sharedManager {
    static ZHRequestManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!mgr) {
            mgr = [[self alloc] init];
        }
    });
    return mgr;
}

- (instancetype)init {
    if (self = [super init]) {
        self.requestRecord = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (void)addRequest:(ZHBaseRequest *)request {
    
}

+ (void)cancelAllRequests {
    
}

+ (void)cancelRequest:(ZHBaseRequest *)request {
    
}

@end
