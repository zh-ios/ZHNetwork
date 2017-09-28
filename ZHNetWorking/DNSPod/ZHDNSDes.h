//
//  QNDes.h
//  HappyDNS
//
//  Created by bailong on 15/8/1.
//  Copyright (c) 2015年 Qiniu Cloud Storage. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int kQN_ENCRYPT_FAILED;
extern const int kQN_DECRYPT_FAILED;

@interface ZHDNSDes : NSObject

+ (NSData *)encrypt:(NSData*)data withKey:(NSData *)key;


+ (NSData *)decrpyt:(NSData*)raw withKey:(NSData *)key;

@end
