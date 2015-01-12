//
//  ThumbnailViewController.h
//  Toyshow
//
//  Created by zhxf on 14-3-28.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThumbnailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *thumbPic;
@property (weak, nonatomic) IBOutlet UILabel *thumbTitle;
@property (weak, nonatomic) IBOutlet UILabel *thumbDeadlines;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) NSString *deviceDesc;
@property (copy, nonatomic) NSString *deviceID;
@property (copy, nonatomic) NSString *accessToken;
@end
