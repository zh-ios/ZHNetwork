//
//  ZHBatchRequest.h
//  ZHNetWorking
//
//  Created by autohome on 2017/9/20.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import "ZHBatchRequest.h"
#import <Foundation/Foundation.h>

@class ZHRequest;

@protocol ZHBatchRequestDelegate <NSObject>

@optional;
- (void)batchRequestFinished:(NSArray <ZHRequest *>*)requestArr;
- (void)batchRequestFailed:(NSArray <ZHRequest *>*)requestArr;
@end

@interface ZHBatchRequest : NSObject

@property(nonatomic, strong, readonly) NSArray<ZHRequest *> *requestArr;

- (void)start;
- (void)stop;

- (instancetype)initWithRequestArray:(NSArray<ZHRequest *> *)requestArr;
@end
