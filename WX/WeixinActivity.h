//
//  WeixinActivity.h
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "QQApi.h"
#import "QQApiInterface.h"

enum scene1
{
    WXSceneSession0 = 0,
    WXSceneTimeline1 = 1,
    QQReq,
    QQZone,
}scence;

@interface WeixinActivity : UIActivity {
    NSString *title;
    NSString *description;
    UIImage *image;
    NSURL *url;
//    enum WXScene scene;
    enum  scene1 scene;
}

@end
