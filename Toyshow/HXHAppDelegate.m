//
//  HXHAppDelegate.m
//  Toyshow
//
//  Created by zhxf on 14-2-27.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "HXHAppDelegate.h"
//#import "HomeViewController.h"
#import <Frontia/Frontia.h>
//#import "ShowImageViewController.h"

#define APP_KEY @"ZIAgdlC7Vw7syTjeKG9zS4QP"
#define REPORT_ID @"2271149"

@implementation HXHAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [SliderViewController sharedSliderController].LeftVC=[[LeftViewController alloc] init];
    [SliderViewController sharedSliderController].RightVC=[[RightViewController alloc] init];
    [SliderViewController sharedSliderController].RightSContentOffset=260;
    [SliderViewController sharedSliderController].RightSContentScale=0.6;
    [SliderViewController sharedSliderController].RightSOpenDuration=0.8;
    [SliderViewController sharedSliderController].RightSCloseDuration=0.8;
    [SliderViewController sharedSliderController].RightSJudgeOffset=160;
//    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"firstLanuch"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirst"];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[SliderViewController sharedSliderController]];
    self.window.backgroundColor = [UIColor whiteColor];
//    UINavigationController *nav;
//    if (flag) {
//        ShowImageViewController *showImage = [[ShowImageViewController alloc] init];
//        nav = [[UINavigationController alloc] initWithRootViewController:showImage];
//    }else
//    {
//        HomeViewController *homeVC = [[HomeViewController alloc] init];
//        nav = [[UINavigationController alloc] initWithRootViewController:homeVC];
//    }
//    flag = YES;
//    self.window.rootViewController = nav;
    
    [self.window makeKeyAndVisible];
//    //初始化Frontia
    [Frontia initWithApiKey:APP_KEY];
    
    [Frontia getPush];
    [FrontiaPush setupChannel:launchOptions];
    
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert
     | UIRemoteNotificationTypeBadge
     | UIRemoteNotificationTypeSound];
    
//    FrontiaStatistics* statTracker = [Frontia getStatistics];//集成百度云集成服务
//    statTracker.enableExceptionLog = YES; // 是否允许截获并发送崩溃信息，请设置YES或者NO
//    statTracker.channelId = @"this_is_a_invalid_channel_ID";//设置您的app的发布渠道
//    statTracker.logStrategy = FrontiaStatLogStrategyCustom;//根据开发者设定的时间间隔接口发送 也可以使用启动时发送策略
//    statTracker.logSendInterval = 1;  //为1时表示发送日志的时间间隔为1小时
//    statTracker.logSendWifiOnly = YES; //是否仅在WIfi情况下发送日志数据
//    statTracker.sessionResumeInterval = 60;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
//    statTracker.shortAppVersion  = IosAppVersion; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
//    [statTracker startWithReportId:REPORT_ID];//设置您在mtj网站上添加的app的appkey
    

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+(HXHAppDelegate*)instance
{
	return (HXHAppDelegate *)[[UIApplication sharedApplication] delegate];
}
@end
