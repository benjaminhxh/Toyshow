//
//  NetworkRequest.h
//  Toyshow
//
//  Created by zhxf on 14-3-24.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkRequest : NSObject

+(NetworkRequest*)shareInstance;

- (NSDictionary*)requestWithURL:(NSString *)url setHTTPMethod:(NSString *)httpMethod;

@end
