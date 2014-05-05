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
@end
