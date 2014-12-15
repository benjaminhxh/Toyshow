//
//  QQZoneActivity.m
//  Joyshow
//
//  Created by xiaohuihu on 14/12/12.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "QQZoneActivity.h"

@implementation QQZoneActivity

- (id)init
{
    self = [super init];
    if (self) {
        scene = 3;
    }
    return self;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_timeline.png"];
}

- (NSString *)activityTitle
{
    return @"QQ空间";
}

@end
