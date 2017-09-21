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
@class ZHBatchRequest;
@protocol ZHBatchRequestDelegate <NSObject>

@optional;
- (void)batchRequestFinished:(ZHBatchRequest *)batchRequest;
- (void)batchRequestFailed:(ZHBatchRequest *)batchRequest;
- (void)batchRequestWillStart:(ZHBatchRequest *)batchRequest;
@end

@interface ZHBatchRequest : NSObject

@property(nonatomic, strong, readonly) NSArray<ZHRequest *> *requestArr;
@property(nonatomic, weak) id<ZHBatchRequestDelegate> delegate;

- (void)start;
- (void)stop;
- (instancetype)initWithRequestArray:(NSArray<ZHRequest *> *)requestArr;
@end
