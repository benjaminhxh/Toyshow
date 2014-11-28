//
//  NSString+encodeChinese.m
//  Joyshow
//
//  Created by xiaohuihu on 14-10-13.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "NSString+encodeChinese.h"
#import <CommonCrypto/CommonCrypto.h>
@implementation NSString (encodeChinese)

- (NSString *)encodeChinese{
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

+ (NSString *)getMd5_32Bit_String:(NSString *)inputString
{
    const char* str = [inputString UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    NSMutableString *returnHashSum = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [returnHashSum appendFormat:@"%02x", result[i]];
    }
    return returnHashSum;
}
@end
