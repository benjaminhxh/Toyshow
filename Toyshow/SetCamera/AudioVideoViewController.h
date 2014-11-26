//
//  AudioVideoViewController.h
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioVideoViewController : UIViewController

@property (nonatomic, assign) BOOL isLow;
@property (copy ,nonatomic) NSString *access_token;
@property (copy ,nonatomic) NSString *deviceid;
@property (nonatomic, assign) NSInteger audioIndex;
@property (nonatomic, copy) NSString *streamIndex;
@property (nonatomic, assign) NSInteger flipImageIndex;
@property (nonatomic, assign) NSInteger ntscOrPalIndex;
//@property (nonatomic, assign) NSInteger imageResolutionIndex;
@property (nonatomic, assign) NSInteger iMainStreamUserOption;
@end
