//
//  MD5Tools.h
//  AHNetworking
//
//  Created by 周策 on 15/12/3.
//  Copyright © 2015年 com.autohome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5Tools : NSObject

+ (NSString *)md5FromString:(NSString *)str;

+ (NSString *)stringFromMD5:(NSString *)md5Str;


@end
