//
//  HXHAppDelegate.m
//  Toyshow
//
//  Created by zhxf on 14-2-27.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "HXHAppDelegate.h"
#import "ShowImageViewController.h"

#define APP_KEY @"ZIAgdlC7Vw7syTjeKG9zS4QP"
#define REPORT_ID @"2271149"
#define APP_ID @"2271149"
#define APP_SecrectKey @"pavlqfU4mzYQ1dH0NG3b7LyXNBy5SYk6"

@implementation HXHAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [NSThread sleepForTimeInterval:3];//延迟启动
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    //判断是否第一次进入
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"first"]) {
        ShowImageViewController *firstVC = [[ShowImageViewController alloc] init];
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:firstVC];
    }else{
    [SliderViewController sharedSliderController].LeftVC=[[LeftViewController alloc] init];
    [SliderViewController sharedSliderController].RightVC=[[RightViewController alloc] init];
    [SliderViewController sharedSliderController].RightSContentOffset=260;
    [SliderViewController sharedSliderController].RightSContentScale=0.6;
    [SliderViewController sharedSliderController].RightSOpenDuration=0.8;
    [SliderViewController sharedSliderController].RightSCloseDuration=0.8;
    [SliderViewController sharedSliderController].RightSJudgeOffset=160;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirst"];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[SliderViewController sharedSliderController]];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    //初始化Frontia
    [Frontia initWithApiKey:APP_KEY];

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
    
//     [UIApplication sharedApplication].idleTimerDisabled = YES;//app在后台不锁屏
    [WXApi registerApp:@"wx70162e2c344d4c79" withDescription:nil];
    //友盟错误信息统计
//    [MobClick startWithAppkey:@"53ba18ff56240b830200cdab" reportPolicy:SEND_INTERVAL channelId:nil];
    return YES;
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //NSLog(@"frontia application deviceToken:%@", deviceToken);
    [FrontiaPush registerDeviceToken: deviceToken];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //NSLog(@"frontia application error:%@", error);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //NSLog(@"frontia applciation receive Notify: %@", [userInfo description]);
    NSString *alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    if (application.applicationState == UIApplicationStateActive) {
        // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification"
                                                            message:[NSString stringWithFormat:@"The application received this remote notification while it was running:\n%@", alert]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    [application setApplicationIconBadgeNumber:0];
    
    [FrontiaPush handleNotification:userInfo];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
//    //NSLog(@"applicationWillResignActive");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
//    //NSLog(@"applicationDidEnterBackground");
    [[NSNotificationCenter defaultCenter] postNotificationName:kAPPWillResignActivenotif object:nil userInfo:nil];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    //NSLog(@"applicationWillEnterForeground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    //NSLog(@"applicationDidBecomeActive");

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([WXApi handleOpenURL:url delegate:self]) {
        return  [WXApi handleOpenURL:url delegate:self];
    }else
    {
        FrontiaShare *share = [Frontia getShare];
        return [share handleOpenURL:url];
    }
}

//从微信点击回到该APP的时候调用
-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1000;
        [alert show];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
//        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
//        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
//        //NSLog(@"strMSG:%@",strMsg);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
        NSDictionary *weixinInfo = [NSDictionary dictionaryWithObjectsAndKeys:obj.url,@"weixinInfo",msg.title,@"weixinTitle", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shareToWeixinNotif" object:self userInfo:weixinInfo];
        
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = @"这是从微信启动的消息";
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//点击回调的时候
-(void) onResp:(BaseResp*)resp
{
//    if([resp isKindOfClass:[SendMessageToWXResp class]])
//    {
//        NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
//        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d,%@", resp.errCode,resp.errStr];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }
}

+(HXHAppDelegate*)instance
{
	return (HXHAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
