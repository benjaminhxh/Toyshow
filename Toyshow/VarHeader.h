//
//  VarHeader.h
//  Joyshow
//
//  Created by zhxf on 14-7-14.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#ifndef Joyshow_VarHeader_h
#define Joyshow_VarHeader_h

#define leftWidth 220
#define msAK                    @"ZIAgdlC7Vw7syTjeKG9zS4QP"
#define msSK                    @"pavlqfU4mzYQ1dH0NG3b7LyXNBy5SYk6"
#define APP_KEY @"ZIAgdlC7Vw7syTjeKG9zS4QP"
#define APP_ID  @"2271149"
#define WXAPP_ID @"wxd867b3590b97057c"
#define QQAPP_ID @"1103178501"

#define backGroundImage         @"beijing@2x"
#define navigationBarImageiOS7  @"bantou_dida@2x"
#define navigationBarImage      @"bantou_di@2x"
#define backBtnImage            @"cehuajiantou18x34@2x"
#define kUserInfoNotification   @"userInfoNotification"
#define kAPPWillResignActivenotif @"applicationWillResignActive"
//百度用户信息
#define kUserName               @"userName"
#define kUserAccessToken        @"userAccessToken"
#define kUserRefreshToken        @"userRefreshToken"
#define kUserHeadImage          @"userHeadImage"
#define kUserId                 @"userID"
#define kLoginSuccess           @"LoginSuccess"
//播放器
#define kplayerKey              @"playerKey"
#define kplayerDict             @"playerDict"
#define kplayerObj              @"playerObjctNotif"

#define iOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define iphone5     [UIScreen mainScreen].bounds.size.height > 480
#define KdurationFail 8.0
#define KdurationSuccess 1.0

#define kHeight [UIScreen mainScreen].bounds.size.height
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kStatusbarHeight  [UIApplication sharedApplication].statusBarFrame.size.height
#endif
