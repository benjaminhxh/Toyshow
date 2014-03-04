//
//  MVViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-3.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "MVViewController.h"

@interface MVViewController ()

@end

@implementation MVViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//---------------6.0之后使用以下两个方法控制横屏、竖屏--------------------------
- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

@end
