//
//  NSString+encodeChinese.m
//  Joyshow
//
//  Created by xiaohuihu on 14-10-13.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "NSString+encodeChinese.h"

@implementation NSString (encodeChinese)

- (NSString *)encodeChinese{
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

@end
