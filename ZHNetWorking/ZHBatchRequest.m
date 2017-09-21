//
//  ZHBatchRequest.m
//  ZHNetWorking
//
//  Created by autohome on 2017/9/20.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHBatchRequest.h"
#import "ZHRequest.h"
#import "ZHBatchRequestManager.h"
@interface ZHBatchRequest()<ZHRequestDelegate>

@property(nonatomic, strong, readwrite) NSArray<ZHRequest *> *requestArr;

@end

@implementation ZHBatchRequest

- (instancetype)initWithRequestArray:(NSArray<ZHRequest *> *)requestArr {
    if (self = [super init]) {
        self.requestArr = requestArr;
    }
    return self;
}

- (void)start {
    ZHBatchRequestManager *batchManager = [ZHBatchRequestManager sharedManager];
    [batchManager addBatchRequest:self];
}



- (void)stop {
    ZHBatchRequestManager *batchManager = [ZHBatchRequestManager sharedManager];
    [batchManager cancelBatchRequest:self];
}




@end
