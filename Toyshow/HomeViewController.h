//
//  HomeViewController.h
//  Toyshow
//
//  Created by zhxf on 14-2-27.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) NSString *titleT;

@property (weak, nonatomic) IBOutlet UILabel *cameraTitle;
@property (weak, nonatomic) IBOutlet UILabel *cameraId;
@property (weak, nonatomic) IBOutlet UILabel *cameraDirecation;
- (IBAction)moreClick:(id)sender;

@end
