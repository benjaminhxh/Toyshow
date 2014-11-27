//
//  BaiduAuthorizeViewController.m
//  Baidu SDK
//
//  Created by xiawh on 12-9-25.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

#define APP_AK @"ZIAgdlC7Vw7syTjeKG9zS4QP"
#define APP_SK @"pavlqfU4mzYQ1dH0NG3b7LyXNBy5SYk6"
#define APP_ID @"2271149"

#import "BaiduAuthorizeViewController.h"
#import "BaiduUtility.h"
#import "BaiduMacroDef.h"
#import "BaiduConfig.h"
#import "BaiduError.h"
#import "BaiduUserSessionManager.h"
#import <QuartzCore/QuartzCore.h>

#define BAIDU_AUTH_LOADING_VIEW_TAG         101
#define BAIDU_AUTH_LOADING_LABLE_TAG        102

#define BAIDU_AUTH_STATUS_BAR_HEIGHT        20
#define BAIDU_AUTH_NAVIGATION_BAR_HEIGHT    45


@interface BaiduAuthorizeViewController()

- (NSURL *)oauthRequestURLWithScope:(NSString *)scope;

@end

@implementation BaiduAuthorizeViewController
@synthesize scope = _scope;
@synthesize delegate = _delegate;
@synthesize targetController = _targetController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    // Custom initialization
    self.baidu = [[Baidu alloc] initWithAPIKey:APP_AK appId:APP_ID];
    [super loadView];
    CGFloat startY = 0.0f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        startY = BAIDU_AUTH_STATUS_BAR_HEIGHT;
    }
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    navigationBar.frame = CGRectMake(0, startY, self.view.bounds.size.width, BAIDU_AUTH_NAVIGATION_BAR_HEIGHT);
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"百度账号"];
    
    //navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)] autorelease];
    
    navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonSystemItemCancel target:self action:@selector(close)] autorelease];
    
    [navigationBar pushNavigationItem:navigationItem animated:NO];
    [navigationItem release];
    
    [self.view addSubview:navigationBar];
    [navigationBar release];
    
    UIWebView *authWeb = [[UIWebView alloc] init];
    authWeb.frame = CGRectMake(0, startY + BAIDU_AUTH_NAVIGATION_BAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - (startY + BAIDU_AUTH_NAVIGATION_BAR_HEIGHT));
    authWeb.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:authWeb];
    [authWeb release];
    
    UIView *indicatorView = [[UIView alloc] init];
    indicatorView.tag = BAIDU_AUTH_LOADING_VIEW_TAG;
    indicatorView.backgroundColor = [UIColor blackColor];
    indicatorView.bounds = CGRectMake(0, 0, 100, 100);
    indicatorView.center = authWeb.center;
    indicatorView.layer.cornerRadius = 8;
    indicatorView.layer.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7].CGColor;
    [authWeb addSubview:indicatorView];
    
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(50, 40);
    //activityView.tag = BAIDU_AUTH_LOADING_VIEW_TAG;
    [indicatorView addSubview:activityView];
    [activityView release];
    [activityView startAnimating];
    
    UILabel *loadingLable = [[UILabel alloc] initWithFrame:CGRectMake(0,60,100,30)];
    loadingLable.text = [NSString stringWithFormat:@"加载中"];
    loadingLable.backgroundColor = [UIColor clearColor];
    loadingLable.textColor = [UIColor whiteColor];
    loadingLable.textAlignment = UITextAlignmentCenter;
    [indicatorView addSubview:loadingLable];
    [loadingLable release];
    [indicatorView release];
    
    indicatorView.hidden = NO;
    
    NSURL *url = [self oauthRequestURLWithScope:self.scope];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 10;
    [authWeb loadRequest:request];
    authWeb.delegate = self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark - UIWebViewDelegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeFormSubmitted) {
        webView.userInteractionEnabled = NO;
    }
    
    NSURL *url = request.URL;
    BDLog(@"auth url:%@",url);
    NSString *query = [url fragment]; // url中＃字符后面的部分。
    if (!query) {
        query = [url query];
    }
    NSDictionary *params = [BaiduUtility parseURLParams:query];
    NSString *errorReason = [params objectForKey:@"error"];
    NSString *q = [url absoluteString];
    if( errorReason != nil && [q hasPrefix:BDAUTHORIZE_REDIRECTURI]) {
    
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginFailedWithError:)]) {
            BaiduError *error = [BaiduError errorWithOAuthResult:params];
            [self.delegate loginFailedWithError:error];
        }
        [self performSelector:@selector(close)];
        webView.userInteractionEnabled = YES;
        return NO;
    }
    
    if ([q hasPrefix:BDAUTHORIZE_REDIRECTURI]) {
        NSString *code = [params objectForKey:@"code"];
        if (code != nil)
        {
            NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
            for (NSHTTPCookie *cookie in [cookieJar cookies]) {
                /*
                if ([[cookie name] isEqualToString:@"BDUSS"])
                {
                    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:cookie.properties];
                    [defaults setObject:params forKey:BAIDUCOOKIE];
                    [defaults synchronize];
                    [params release];
                }
                */
            }
            NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"authorization_code",code,APP_AK,APP_SK,BDAUTHORIZE_REDIRECTURI,nil] forKeys:[NSArray arrayWithObjects:@"grant_type",@"code",@"client_id",@"client_secret",@"redirect_uri",nil]];
            [self.baidu  apiRequestWithUrl:@"https://openapi.baidu.com/oauth/2.0/token?" httpMethod:@"GET" params:params andDelegate:self];
        }
    }
    
    NSString *accessToken = [params objectForKey:@"access_token"];
    if (nil != accessToken) {
        [[BaiduUserSessionManager shareUserSessionManager].currentUserSession saveUserSessionInfo:params];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginDidSuccess)]) {
            [self.delegate loginDidSuccess];
        }
        [self performSelector:@selector(close)];
        webView.userInteractionEnabled = YES;
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    UIView *indicatorView = [self.view viewWithTag:BAIDU_AUTH_LOADING_VIEW_TAG];
    indicatorView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.userInteractionEnabled = YES;
    UIView *indicatorView = [self.view viewWithTag:BAIDU_AUTH_LOADING_VIEW_TAG];
    indicatorView.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    webView.userInteractionEnabled = YES;
    if (!([error.domain isEqualToString:@"WebKitErrorDomain"] && (error.code == 102 || error.code == 101))) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginFailedWithError:)]) {
            [self performSelector:@selector(close)];
            [self.delegate loginFailedWithError:error];
        }
    }
}

- (NSURL *)oauthRequestURLWithScope:(NSString *)scope
{
//    if (scope==nil) {
//        scope = @"";
//    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [BaiduConfig shareConfig].apiKey,@"client_id",
                                   BDAUTHORIZE_REDIRECTURI,@"redirect_uri",
                                   @"code",@"response_type",
                                   @"mobile",@"display",
                                   @"netdisk",@"scope",
                                   nil];
//    NSLog(@"params:%@",params);
    return [BaiduUtility generateURL:BDAUTHORIZE_HOSTURL params:params];
}

- (void)close
{
    if ([NSClassFromString(@"UIViewController") instancesRespondToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [self dismissViewControllerAnimated:YES completion:^{
            //nothing
        }];
    } else if ([NSClassFromString(@"UIViewController") instancesRespondToSelector:@selector(dismissModalViewControllerAnimated:)]) {
        [self dismissModalViewControllerAnimated:YES];
    }
}

//- (BOOL)prefersStatusBarHidden
//{
//    return NO;
//}
//
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

- (void)apiRequestDidFinishLoadWithResult:(id)result
{
    NSString *accessToken = [result objectForKey:@"access_token"];
    if (nil != accessToken) {
        [[BaiduUserSessionManager shareUserSessionManager].currentUserSession saveUserSessionInfo:result];
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginDidSuccess)]) {
            [self.delegate loginDidSuccess];
//            NSLog(@"登录成功了");
        }
        [self performSelector:@selector(close)];
    }

}

- (void)apiRequestDidFailLoadWithError:(NSError*)error
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginFailedWithError:)]) {
        [self performSelector:@selector(close)];
        [self.delegate loginFailedWithError:error];
    }
}

- (void)dealloc
{
    [self.baidu apiRequestWithUrl:nil httpMethod:nil params:nil andDelegate:nil];
    [self.baidu release];
    self.scope = nil;
    [super dealloc];
}
@end
