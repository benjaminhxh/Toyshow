//
//  WeixinActivity.h
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

@interface WeixinActivity : UIActivity {
    NSString *title;
    NSString *description;
    UIImage *image;
    NSURL *url;
//    NSDictionary *dict;
    enum WXScene scene;
}

@end
