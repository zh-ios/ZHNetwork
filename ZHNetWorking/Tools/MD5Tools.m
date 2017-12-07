//
//  MD5Tools.m
//  AHNetworking
//
//  Created by 周策 on 15/12/3.
//  Copyright © 2015年 com.autohome. All rights reserved.
//

#import "MD5Tools.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MD5Tools

+ (NSString *)md5FromString:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int) strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


+ (NSString *)stringFromMD5:(NSString *)md5Str {
    
    if(md5Str == nil || [md5Str length] == 0)
        return nil;
    
    const char *value = [md5Str UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

@end
