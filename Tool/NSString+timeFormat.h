//
//  NSString+timeFormat.h
//  Joyshow
//
//  Created by xiaohuihu on 15/1/12.
//  Copyright (c) 2015年 zhxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (timeFormat)

+ (NSString *)convertHourMinuteSecondWith:(int)second withSeparate:(NSString *)separate;

@end
