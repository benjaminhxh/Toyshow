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
            if ([activityItem hasPrefix:@"joyshow"]) {
                description = [activityItem substringFromIndex:7];
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
    switch (scene) {
        case 0:
        {
            //分享到好友
            WXMediaMessage *message = [WXMediaMessage message];
            message.title = title;
            message.description = description;
            [message setThumbImage:image];
            if (url) {
                WXAppExtendObject *extedObj = [WXAppExtendObject object];
                extedObj.extInfo = [url absoluteString];
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
            //    reqq.bText = NO;
            reqq.scene = scene;
            reqq.message = message;
            [WXApi sendReq:reqq];
            [self activityDidFinish:YES];
        }
            break;
        case 1:
        {
            //分享到朋友圈
            SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
            req.scene = scene;
            //    req.bText = NO;
            //http://www.51joyshow.com/view_share.php?shareid=1ade5ddf8fec8492358a454b34bd5ec6&uk=474433575
            req.message = WXMediaMessage.message;
            req.message.title = description;
            [self setThumbImage:req];
            if (url) {
                WXWebpageObject *webObject = WXWebpageObject.object;
                NSString *receiveURL = [url absoluteString];
                //截取URL的后半截shareid和uk
                NSArray *arr = [receiveURL componentsSeparatedByString:@"liveplay&"];
                //拼接joyshow官网直播的URL
                NSString *urlString = [NSString stringWithFormat:@"http://www.51joyshow.com/view_share.php?%@",[arr lastObject]];
                webObject.webpageUrl = urlString;
                req.message.mediaObject = webObject;
            } else if (image) {
                WXImageObject *imageObject = WXImageObject.object;
                imageObject.imageData = UIImageJPEGRepresentation(image, 1);
                req.message.mediaObject = imageObject;
            }
            [WXApi sendReq:req];
            [self activityDidFinish:YES];
        }
            break;
            /*
        case 2:
        {
            //分享到QQ
            NSString *receiveURL = [url absoluteString];
            //截取URL的后半截shareid和uk
            NSArray *arr = [receiveURL componentsSeparatedByString:@"liveplay&"];
            //拼接joyshow官网直播的URL
            NSString *urlString = [NSString stringWithFormat:@"http://www.51joyshow.com/view_share.php?%@",[arr lastObject]];

            QQApiNewsObject *qqReq = [QQApiNewsObject objectWithURL:[NSURL URLWithString:urlString] title:title description:description previewImageData:UIImageJPEGRepresentation(image, 1)];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:qqReq];
            if([QQApiInterface isQQInstalled])
            {
                QQApiSendResultCode send = [QQApiInterface sendReq:req];
                NSLog(@"send:%d",send);
            }
        }
            break;
        case 3:
        {
            //分享到QQ空间
            NSString *receiveURL = [url absoluteString];
            //截取URL的后半截shareid和uk
            NSArray *arr = [receiveURL componentsSeparatedByString:@"liveplay&"];
            //拼接joyshow官网直播的URL
            NSString *urlString = [NSString stringWithFormat:@"http://www.51joyshow.com/view_share.php?%@",[arr lastObject]];
            
            QQApiNewsObject *qqReq = [QQApiNewsObject objectWithURL:[NSURL URLWithString:urlString] title:title description:description previewImageData:UIImageJPEGRepresentation(image, 1)];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:qqReq];
            QQApiSendResultCode send = [QQApiInterface SendReqToQZone:req];
        }
            break;
             */
        default:
            break;
    }
    /*
    if (scene) {
        //分享到朋友圈
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.scene = scene;
        //    req.bText = NO;
        //http://www.51joyshow.com/view_share.php?shareid=1ade5ddf8fec8492358a454b34bd5ec6&uk=474433575
        req.message = WXMediaMessage.message;
        req.message.title = description;
        [self setThumbImage:req];
        if (url) {
            WXWebpageObject *webObject = WXWebpageObject.object;
            NSString *receiveURL = [url absoluteString];
            //截取URL的后半截shareid和uk
            NSArray *arr = [receiveURL componentsSeparatedByString:@"liveplay&"];
            //拼接joyshow官网直播的URL
            NSString *urlString = [NSString stringWithFormat:@"http://www.51joyshow.com/view_share.php?%@",[arr lastObject]];
            webObject.webpageUrl = urlString;
            req.message.mediaObject = webObject;
        } else if (image) {
            WXImageObject *imageObject = WXImageObject.object;
            imageObject.imageData = UIImageJPEGRepresentation(image, 1);
            req.message.mediaObject = imageObject;
        }
        [WXApi sendReq:req];
        [self activityDidFinish:YES];
    }else
    {
        //分享到好友
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        message.description = description;
        [message setThumbImage:image];
        if (url) {
            WXAppExtendObject *extedObj = [WXAppExtendObject object];
            extedObj.extInfo = [url absoluteString];
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
    //    reqq.bText = NO;
        reqq.scene = scene;
        reqq.message = message;
        [WXApi sendReq:reqq];
        [self activityDidFinish:YES];
    }
     */
}

@end
