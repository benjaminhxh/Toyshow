//
//  BDConnect.m
//  Baidu SDK
//
//  Created by xiawh on 12-9-25.
//  Copyright (c) 2012年 Baidu. All rights reserved.
//

#import "Baidu.h"
#import "BaiduConfig.h"
#import "BaiduAuthorizeViewController.h"
#import "BaiduUserSessionManager.h"
#import "BaiduAPIRequest.h"

#define APP_AK @"ZIAgdlC7Vw7syTjeKG9zS4QP"
#define APP_SK @"pavlqfU4mzYQ1dH0NG3b7LyXNBy5SYk6"

@interface Baidu()

@property (nonatomic,retain)BaiduAPIRequest *request;

@end

@implementation Baidu
@synthesize request = _request;

- (id)initWithAPIKey:(NSString *)apiKey appId:(NSString *)appId
{
    if (self = [super init]) {
        [[BaiduConfig shareConfig] setApiKey:apiKey];
        [[BaiduConfig shareConfig] setAppId:appId];
        self.request = [[[BaiduAPIRequest alloc] init] autorelease];
    }
    
    return self;
}

- (BOOL)isUserSessionValid
{
    return [[BaiduUserSessionManager shareUserSessionManager].currentUserSession isUserSessionValid];
}

- (void)authorizeWithTargetViewController:(UIViewController *)targetViewController scope:(NSString*)scope andDelegate:(id<BaiduAuthorizeDelegate>)delegate
{
    if ([[BaiduUserSessionManager shareUserSessionManager].currentUserSession isUserSessionValid]) {
        return;
    }
    
    BaiduAuthorizeViewController *authController = [[BaiduAuthorizeViewController alloc] init];
    authController.delegate = delegate;
    authController.scope = scope;
    
    //authController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    if ([NSClassFromString(@"UIViewController") instancesRespondToSelector:@selector(presentViewController:animated:completion:)]) {
        [targetViewController presentViewController:authController animated:YES completion:^{
            //nothing
        }];
    } else if ([NSClassFromString(@"UIViewController") instancesRespondToSelector:@selector(presentModalViewController:animated:)]) {
        [targetViewController presentModalViewController:authController animated:YES];
    }
    
    [authController release];
}

- (void)currentUserLogout
{
    [[BaiduUserSessionManager shareUserSessionManager].currentUserSession logout];
}

- (void)apiRequestWithUrl:(NSString *)requestUrl
               httpMethod:(NSString *)httpMethod
                   params:(NSDictionary *)params
              andDelegate:(id<BaiduAPIRequestDelegate>)delegate
{
    //login  1
    NSMutableDictionary *completeParams = [NSMutableDictionary dictionaryWithDictionary:params];
    if ( requestUrl != nil && [requestUrl rangeOfString:@"/public/"].location == NSNotFound) {
        if ([BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken != nil)
        {
            [completeParams setObject:[BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken forKey:@"access_token"];
        }
    }
    [completeParams setObject:@"json" forKey:@"format"];
    
    [self.request apiRequestWithUrl:requestUrl httpMethod:httpMethod params:completeParams andDelegate:delegate];
}

- (void)refreshUserToken
{
//    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"refresh_token",[BaiduUserSessionManager shareUserSessionManager].currentUserSession.refreshToken,APP_AK,APP_SK,nil] forKeys:[NSArray arrayWithObjects:@"grant_type",@"refresh_token",@"client_id",@"client_secret",nil]];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"addusertoken",[BaiduUserSessionManager shareUserSessionManager].currentUserSession.refreshToken,[BaiduUserSessionManager shareUserSessionManager].currentUserSession.accessToken,nil] forKeys:[NSArray arrayWithObjects:@"method",@"refresh_token",@"access_token",nil]];

    [self.request  apiRequestWithUrl:@"https://pcs.baidu.com/rest/2.0/pcs/device?" httpMethod:@"GET" params:params andDelegate:self];

//    [self.request  apiRequestWithUrl:@"https://openapi.baidu.com/oauth/2.0/token?" httpMethod:@"GET" params:params andDelegate:self];
}

- (void)apiRequestDidFinishLoadWithResult:(id)result
{
    if (nil != [result objectForKey:@"access_token"]) {
        [[BaiduUserSessionManager shareUserSessionManager].currentUserSession saveUserSessionInfo:result];
    }
}

- (void)apiRequestDidFailLoadWithError:(NSError*)error
{

}

- (void)dealloc
{
    self.request = nil;
    [BaiduUserSessionManager destroyUserSessionManager];
    [BaiduConfig destroyConfig];
    [super dealloc];
}

@end
