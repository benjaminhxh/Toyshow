//
//  LeftViewController.h
//  LeftRightSlider
//
//  Created by Zhao Yiqi on 13-11-27.
//  Copyright (c) 2014年 Zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeftViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageIcon;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (copy, nonatomic) NSString *titleT;
@property (copy, nonatomic) NSString *accessToken;
@property (nonatomic, strong) UIImageView *line;
@property (nonatomic, strong) UIImageView *userImageVIew;
@property (nonatomic, strong) UILabel *userNameL;

//- (void)signonButtonClicked;
- (void)loginBaidu;
@end
