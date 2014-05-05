//
//  NetworkRequest.m
//  Toyshow
//
//  Created by zhxf on 14-3-24.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "NetworkRequest.h"

static NetworkRequest *_request;

@implementation NetworkRequest

+ (NetworkRequest *)shareInstance
{
    if (!_request) {
        _request = [[NetworkRequest alloc] init];
    }
    return _request;
}

- (id)requestWithURL:(NSString *)url setHTTPMethod:(NSString *)httpMethod
{
//    NSDictionary *__block downloadDict;
    id __block downloadDict;
    NSURL *requestURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:httpMethod];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSString *errorStr = [NSString stringWithFormat:@"%@",connectionError];
            UIAlertView *failView = [[UIAlertView alloc] initWithTitle:@"连接失败"
                                                               message:errorStr
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil, nil];
            [failView show];
            return ;
        }
        //解析Data，判断是否请求成功
        downloadDict = [NSJSONSerialization JSONObjectWithData:data
                                                       options:NSJSONReadingMutableLeaves
                                                         error:nil];
    }];
    return downloadDict;
}

@end
