//
//  NSString+timeFormat.m
//  Joyshow
//
//  Created by xiaohuihu on 15/1/12.
//  Copyright (c) 2015年 zhxf. All rights reserved.
//

#import "NSString+timeFormat.h"

@implementation NSString (timeFormat)

+ (NSString *)convertHourMinuteSecondWith:(int)second withSeparate:(NSString *)separate
{
    int hour = 0, minute = 0;
    hour = second / 3600;
    minute = (second - hour * 3600) / 60;
    second = second - hour * 3600 - minute *  60;
    
    NSString* formatter = hour < 10 ? @"0%d" : @"%d";
    NSString* strHour = [NSString stringWithFormat:formatter, hour];
    
    formatter = minute < 10 ? @"0%d" : @"%d";
    NSString* strMinute = [NSString stringWithFormat:formatter, minute];
    
    formatter = second < 10 ? @"0%d" : @"%d";
    NSString* strSecond = [NSString stringWithFormat:formatter, second];
    
    return [NSString stringWithFormat:@"%@%@%@%@%@", strHour,separate, strMinute,separate, strSecond];
}
@end
