//
//  WeixinActivity.m
//  WeixinActivity
//
//  Created by Johnny iDay on 13-12-2.
//  Copyright (c) 2013年 Johnny iDay. All rights reserved.
//

#import "WeixinActivity.h"

@implementation WeixinActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            return YES;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            image = activityItem;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            url = activityItem;
        }
        if ([activityItem isKindOfClass:[NSString class]]) {
            if ([activityItem hasPrefix:@"hxh"]) {
                description = [activityItem substringFromIndex:3];
            }else{
                title = activityItem;
            }
        }
    }
}

- (void)setThumbImage:(SendMessageToWXReq *)req
{
    if (image) {
        CGFloat width = 100.0f;
        CGFloat height = image.size.height * 100.0f / image.size.width;
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        [image drawInRect:CGRectMake(0, 0, width, height)];
        UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [req.message setThumbImage:scaledImage];
    }
}

- (void)performActivity
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:image];
    if (url) {
        WXAppExtendObject *extedObj = [WXAppExtendObject object];
        extedObj.url = [url absoluteString];
        Byte* pBuffer = (Byte *)malloc(BUFSIZ);
        memset(pBuffer, 0, BUFSIZ);
        NSData* data = [NSData dataWithBytes:pBuffer length:BUFSIZ];
        free(pBuffer);
        extedObj.fileData = data;
        message.mediaObject = extedObj;
    } else if (image) {
        WXImageObject *imageObject = WXImageObject.object;
        imageObject.imageData = UIImageJPEGRepresentation(image, 1);
        message.mediaObject = imageObject;
    }
    
    SendMessageToWXReq* reqq = [[SendMessageToWXReq alloc] init];
    reqq.bText = NO;
    reqq.scene = scene;
    reqq.message = message;
    [WXApi sendReq:reqq];
    [self activityDidFinish:YES];

}

@end
