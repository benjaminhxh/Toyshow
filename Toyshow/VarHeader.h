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
#define backGroundImage         @"beijing@2x"
#define navigationBarImageiOS7  @"bantou_dida@2x"
#define navigationBarImage      @"bantou_di@2x"
#define backBtnImage            @"cehuajiantou18x34@2x"
#define kUserInfoNotification   @"userInfoNotification"

#define kUserName               @"userName"
//#define kUserPwd                @"userPwd"
//#define kUserHeadURL            @"userHeadURL"
#define kUserAccessToken        @"userAccessToken"
#define kUserHeadImage          @"userHeadImage"

#define iOS7 [[UIDevice currentDevice].systemVersion integerValue]>=7
#define iphone5     [UIScreen mainScreen].bounds.size.height > 480
#define KdurationFail 8.0
#define KdurationSuccess 1.0

#define kHeight [UIScreen mainScreen].bounds.size.height
#define kWidth  [UIScreen mainScreen].bounds.size.width

#endif
