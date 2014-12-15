//
//  QQReqActivity.m
//  Joyshow
//
//  Created by xiaohuihu on 14/12/12.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "QQReqActivity.h"

@implementation QQReqActivity

- (id)init
{
    self = [super init];
    if (self) {
        scene = 2;
    }
    return self;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_timeline.png"];
}

- (NSString *)activityTitle
{
    return @"QQ好友";
}

@end
