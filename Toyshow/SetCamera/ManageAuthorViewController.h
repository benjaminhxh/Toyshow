//
//  ManageAuthorViewController.h
//  Joyshow
//
//  Created by xiaohuihu on 14/12/19.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageAuthorViewController : UIViewController

@property (nonatomic, copy) NSString *deviceID;
@property (weak, nonatomic) IBOutlet UILabel *accountName;
@property (weak, nonatomic) IBOutlet UILabel *authorCode;
@end
