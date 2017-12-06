//
//  ZHBaseServiceDelegate.h
//  ZHNetWorking
//
//  Created by autohome on 2017/12/5.
//  Copyright © 2017年 autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZHBaseServiceDelegate <NSObject>

- (void)requestWillStart:(NSInteger)handle;

- (void)requestFinished:(NSString *)responseStr
             serviceObj:(id)obj
                 handle:(NSInteger)handle;

- (void)requestFinished:(NSData *)responseData
            responseStr:(NSString *)responseStr
             serviceObj:(id)obj
                 handle:(NSInteger)handle;



- (void)requestFailed:(NSError *)error
           serviceObj:(id)obj
               handle:(NSInteger)handle;

- (void)requestFailed:(NSError *)error
            errorCode:(NSUInteger)errorCode
             errorMsg:(NSString *)errorMsg
           serviceObj:(id)obj
               handle:(NSInteger)handle;

- (void)requestWillRetry:(id)serviceObj handle:(NSInteger)handle isAsync:(BOOL)async;


- (void)requestRedirected:(id)serviceObj handle:(NSInteger)handle;

@end
