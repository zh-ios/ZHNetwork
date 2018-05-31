//
//  ZHBatchRequestManager.m
//  ZHNetWorking
//
//  Created by autohome on 2017/9/20.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHBatchRequestManager.h"
#import "ZHRequest.h"
#import "ZHBatchRequest.h"
@implementation ZHBatchRequestManager

+ (instancetype)sharedManager {
    static ZHBatchRequestManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[self alloc] init];
        }
    });
    return _manager;
}

- (void)addBatchRequest:(ZHBatchRequest *)batchRequest {
    
    if ([batchRequest.delegate respondsToSelector:@selector(batchRequestWillStart:)]) {
        [batchRequest.delegate batchRequestWillStart:batchRequest];
    }
    
    NSAssert(batchRequest&&batchRequest.requestArr.count>0, @"batchRequest不能为空，requestArr不能为空");
    dispatch_group_t  group = dispatch_group_create();
    for (ZHRequest *request in batchRequest.requestArr) {
        dispatch_group_enter(group);
        dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
            [request start];
            request.successBlock = ^(id responseObj) {
                dispatch_group_leave(group);
            };
            // 有一个请求失败了，则取消其他的请求
            request.failureBlock = ^(NSError *error) {
                [self cancelBatchRequest:batchRequest];
                if ([batchRequest.delegate respondsToSelector:@selector(batchRequestFailed:)]) {
                    [batchRequest.delegate batchRequestFailed:batchRequest];
                    return;
                }
            };
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // batchRequest 完成回调
        if ([batchRequest.delegate respondsToSelector:@selector(batchRequestFinished:)]) {
            [batchRequest.delegate batchRequestFinished:batchRequest];
        }
        NSLog(@"------------batchRequestFinish--------------👍");
    });
}


- (void)cancelBatchRequest:(ZHBatchRequest *)batchRequest {
    for (ZHRequest *request in batchRequest.requestArr) {
        [request cancel];
        request.successBlock = nil;
        request.failureBlock = nil;
    }
}

@end
