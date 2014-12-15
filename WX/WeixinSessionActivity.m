//
//  WeixinSessionActivity.m
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import "WeixinSessionActivity.h"

@implementation WeixinSessionActivity

- (id)init
{
    self = [super init];
    if (self) {
        scene = 0;
    }
    return self;
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"icon_session.png"];
}

- (NSString *)activityTitle
{
    return @"微信好友";
}

@end
